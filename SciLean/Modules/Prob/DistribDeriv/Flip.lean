import SciLean.Modules.Prob.DistribDeriv.DistribDeriv
import SciLean.Modules.Prob.DistribDeriv.DistribFwdDeriv

namespace SciLean.Prob

variable
  {W} [NormedAddCommGroup W] [NormedSpace ℝ W] [FiniteDimensional ℝ W] [MeasurableSpace W]
  {X} [NormedAddCommGroup X] [NormedSpace ℝ X] [FiniteDimensional ℝ X] [MeasurableSpace X]
  {Y} [NormedAddCommGroup Y] [NormedSpace ℝ Y] [FiniteDimensional ℝ Y] [MeasurableSpace Y]
  {Z} [NormedAddCommGroup Z] [NormedSpace ℝ Z] [FiniteDimensional ℝ Z] [MeasurableSpace Z]


noncomputable
def flip (θ : ℝ) : Distribution Bool := fun φ => θ • φ true + (1-θ) • φ false

def dflip : Distribution Bool := fun φ => φ true - φ false

noncomputable
def fdflip (θ dθ : ℝ) : FDistribution Bool := ⟨flip θ, dθ • dflip⟩


-- @[fprop]
theorem flip.differentiableAt (f : X → ℝ) (φ : Bool → ℝ) (x : X)
    (hf : DifferentiableAt ℝ f x) :
    DifferentiableAt ℝ (fun x => flip (f x) φ) x := by dsimp[flip]; fprop


-- @[fprop]
theorem dirac.bind._arg_xf.differentiableAt (g : X → ℝ) (f : X → Bool → Distribution Z) (φ : Z → ℝ) (x : X)
    (hg : DifferentiableAt ℝ g x) (hf : ∀ b, DifferentiableAt ℝ (fun x => f x b φ) x)  :
    DifferentiableAt ℝ (fun x => (flip (g x)).bind (f x) φ) x := by unfold flip Distribution.bind; fprop


@[simp ↓]
theorem flip.distribDeriv_comp (f : X → ℝ) (x dx : X) (φ : Bool → ℝ)
    (hg : DifferentiableAt ℝ f x) :
    distribDeriv (fun x : X => flip (f x)) x dx φ
    =
    let dy := fderiv ℝ f x dx
    dy • dflip φ  := by

  unfold distribDeriv flip dflip
  ftrans; dsimp; ring


@[simp ↓]
theorem flip.bind.arg_xf.distribDeriv_rule
    (g : X → ℝ) (f : X → Bool → Distribution Z) (x dx) (φ : Z → ℝ)
    (hg : DifferentiableAt ℝ g x) (hf : ∀ b, DifferentiableAt ℝ (fun x => f x b φ) x) :
    distribDeriv (fun x' => (flip (g x')).bind (f x')) x dx φ
    =
    let y := g x
    let dy := fderiv ℝ g x dx
    (dy • dflip).bind (f x ·) φ
    +
    (flip y).bind (fun y => distribDeriv (f · y) x dx) φ := by

  simp [distribDeriv, flip, dflip, Distribution.bind]
  ftrans; dsimp
  ring


@[simp ↓]
theorem flip.distribFwdDeriv_comp (f : X → ℝ) (x dx : X) (φ : Bool → ℝ×ℝ)
    (hg : DifferentiableAt ℝ f x) :
    distribFwdDeriv (fun x : X => flip (f x)) x dx φ
    =
    let ydy := fwdFDeriv ℝ f x dx
    fdflip ydy.1 ydy.2 φ := by

  unfold distribFwdDeriv
  simp (disch := assumption) only [FDistribution_apply, distribDeriv_comp]
  rfl


@[simp ↓]
theorem flip.bind.arg_xf.distribFwdDeriv_rule
    (g : X → ℝ) (f : X → Bool → Distribution Z) (x dx) (φ : Z → ℝ×ℝ)
    (hg : DifferentiableAt ℝ g x) (hf : ∀ b, DifferentiableAt ℝ (fun x => f x b (fun x => (φ x).1)) x) :
    distribFwdDeriv (fun x' => (flip (g x')).bind (f x')) x dx φ
    =
    let ydy := fwdFDeriv ℝ g x dx
    (fdflip ydy.1 ydy.2) (fun y => distribFwdDeriv (f · y) x dx φ) := by

  unfold distribFwdDeriv fdflip
  simp (disch:=assumption) [FDistribution_apply, Distribution.bind,FDistribution.bind, fwdFDeriv, Pi.add_apply, Prod.mk.injEq, true_and,flip]
  ring