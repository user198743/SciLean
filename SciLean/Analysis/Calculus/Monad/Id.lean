import SciLean.Analysis.Calculus.Monad.FwdDerivMonad
import SciLean.Analysis.Calculus.Monad.RevDerivMonad

namespace SciLean

-- TODO: screw `Id` monad, define new `Id'` will wrap value in a structure
--       that way `Id'` can't abuse defeq and mess up the differentiation process

/-- Identity monad used for differentiating through imperative code.

When you write imperative code in `Id` monad and you want to differentiate it then please use `Id'`
instead. This is due to unfortunate fact that `Id X` is defeq `X` and this confuses autodiff
at some point. It leads to some unification issues that we were unable to solve. Using `Id'`
instead prevents defeq abuse and all these issues go away.
 -/
structure Id' (X : Type) where
  run : X

instance : Monad Id' where
  pure x := ⟨x⟩
  bind x f := f x.run

instance : LawfulMonad Id' where
  map_const := by aesop
  id_map := by aesop
  seqLeft_eq := by aesop
  seqRight_eq := by aesop
  pure_seq := by aesop
  bind_pure_comp := by aesop
  bind_map := by aesop
  pure_bind := by aesop
  bind_assoc := by aesop

instance : Coe (Id' X) X := ⟨fun x => x.run⟩
instance : Coe X (Id' X) := ⟨fun x => pure x⟩

variable
  {K : Type _} [RCLike K]

noncomputable
instance : FwdDerivMonad K Id' Id' where
  fwdDerivM f := fun x dx => pure (fwdDeriv K (fun x => (f x).run) x dx)
  CDifferentiableM f := CDifferentiable K (fun x => (f x).run)
  fwdDerivM_pure f := by simp[pure]
  fwdDerivM_bind := by simp[Id',Bind.bind]; sorry_proof
  fwdDerivM_pair y := by intros; simp; sorry_proof
  CDifferentiableM_pure := by simp[pure]
  CDifferentiableM_bind := by intros; simp[bind]; sorry_proof
  CDifferentiableM_pair y := by intros; simp[bind,pure]; fun_prop


noncomputable
instance : RevDerivMonad K Id' Id' where
  revDerivM f := fun x =>
    let ydf := revDeriv K (fun x => (f x).run) x
    pure ((ydf.1, fun dy => pure (ydf.2 dy)))
  HasAdjDiffM f := HasAdjDiff K (fun x => (f x).run)
  revDerivM_pure f := by intros; funext; simp[pure,revDeriv]
  revDerivM_bind := by intros; simp; sorry_proof
  revDerivM_pair y := by intros; simp[Bind.bind]; funext x; sorry_proof
  HasAdjDiffM_pure := by simp[pure]
  HasAdjDiffM_bind := by intros; simp[bind]; sorry_proof
  HasAdjDiffM_pair y := by intros; simp[bind, pure]; fun_prop


end SciLean
open SciLean


section OnVec

variable
  {K : Type _} [RCLike K]
  {X : Type} [Vec K X]
  {Y : Type} [Vec K Y]
  {Z : Type} [Vec K Z]
  {E : ι → Type _} [∀ i, Vec K (E i)]

@[fun_prop]
theorem Id'.run.arg_x.CDifferentiable_rule
  (a : X → Id' Y) (ha : CDifferentiableM K a)
  : CDifferentiable K (fun x => Id'.run (a x)) := ha

@[fun_trans]
theorem Id'.run.arg_x.fwdDeriv_rule (a : X → Id' Y)
  : fwdDeriv K (fun x => Id'.run (a x))
    =
    fun x dx => (fwdDerivM K a x dx).run := by rfl

end OnVec

section OnSemiInnerProductSpace

variable
  {K : Type _} [RCLike K]
  {X : Type} [SemiInnerProductSpace K X]
  {Y : Type} [SemiInnerProductSpace K Y]
  {Z : Type} [SemiInnerProductSpace K Z]
  {E : ι → Type _} [∀ i, SemiInnerProductSpace K (E i)]


@[fun_prop]
theorem Id'.run.arg_x.HasAdjDiff_rule
  (a : X → Id' Y) (ha : HasAdjDiffM K a)
  : HasAdjDiff K (fun x => Id'.run (a x)) := ha


@[fun_trans]
theorem Id'.run.arg_x.revDeriv_rule (a : X → Id' Y)
  : revDeriv K (fun x => Id'.run (a x))
    =
    fun x =>
      let ydf := (revDerivM K a x).run
      (ydf.1, fun dy => (ydf.2 dy).run) := by rfl


@[fun_prop]
theorem Pure.pure.arg_a0.HasAdjDiff_rule
    (a0 : X → Y) (ha0 : HasAdjDiff K a0) :
    HasAdjDiffM K (fun x => Pure.pure (f:=Id') (a0 x)) := by
  simp[Pure.pure,HasAdjDiffM]; fun_prop


@[fun_trans]
theorem Pure.pure.arg_a0.fwdDeriv_rule
    (a0 : X → Y) :
    fwdDerivM K (fun x => Pure.pure (f:=Id') (a0 x))
    =
    fun x dx =>
      let ydy := fwdDeriv K a0 x dx
      pure ydy := by rfl


@[fun_prop]
theorem Bind.bind.arg_a0a1.HasAdjDiff_rule_on_Id'
    (a0 : X → Y) (a1 : X → Y → Z)
    (ha0 : HasAdjDiff K a0) (ha1 : HasAdjDiff K (fun (x,y) => a1 x y)) :
    HasAdjDiffM K (fun x => Bind.bind (m:=Id') ⟨a0 x⟩ (fun y => ⟨a1 x y⟩)) := by
  simp[Bind.bind,HasAdjDiffM]; fun_prop


@[fun_trans]
theorem Bind.bind.arg_a0a1.revDerivM_rule_on_Id'
    (a0 : X → Y) (a1 : X → Y → Z)
    (ha0 : HasAdjDiff K a0) (ha1 : HasAdjDiff K (fun (x,y) => a1 x y)) :
    (revDerivM (m:=Id') K (fun x => Bind.bind ⟨a0 x⟩ (fun y => ⟨a1 x y⟩)))
    =
    fun x =>
      let ydg' := revDeriv K a0 x
      let zdf' := revDeriv K (fun (x,y) => a1 x y) (x,ydg'.1)
      ⟨(zdf'.1,
       fun dz' =>
         let dxy' := zdf'.2 dz'
         let dx' := ydg'.2 dxy'.2
         ⟨dxy'.1 + dx'⟩)⟩ := by
  simp[revDerivM,Bind.bind]; fun_trans; simp[revDeriv,revDerivUpdate]; sorry_proof



end OnSemiInnerProductSpace
