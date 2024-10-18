import SciLean.Data.IndexType.Operations

namespace SciLean

namespace IndexType

variable {ι : Type*} [IndexType ι]

@[specialize] def sum {α : Type u} [Zero α] [Add α] (f : ι → α) : α :=
  IndexType.reduceD f (fun (s : α) a => s + a) (0 : α)

open Lean.TSyntax.Compat in
macro (priority:=high) " ∑ " xs:Lean.explicitBinders ", " b:term:66 : term => Lean.expandExplicitBinders ``sum xs b

@[app_unexpander sum] def unexpandSum : Lean.PrettyPrinter.Unexpander
  | `($(_) fun $x:ident => $b) =>
    `(∑ $x:ident, $b)
  | `($(_) fun $x:ident $xs:ident* => $b) =>
    `(∑ $x:ident, fun $xs* => $b)
  | `($(_) fun ($x:ident : $ty:term) => $b) =>
    `(∑ ($x:ident : $ty), $b)
  | _  => throw ()


@[specialize] def product {α} [One α] [Mul α] {ι} [IndexType ι] (f : ι → α) : α :=
  IndexType.reduceD f (fun (s : α) a => s * a) 1

open Lean.TSyntax.Compat in
macro (priority:=high) " ∏ " xs:Lean.explicitBinders ", " b:term:66 : term => Lean.expandExplicitBinders ``product xs b

@[app_unexpander product] def unexpandProduct : Lean.PrettyPrinter.Unexpander
  | `($(_) fun $x:ident => $b) =>
    `(∏ $x:ident, $b)
  | `($(_) fun $x:ident $xs:ident* => $b) =>
    `(∏ $x:ident, fun $xs* => $b)
  | `($(_) fun ($x:ident : $ty:term) => $b) =>
    `(∏ ($x:ident : $ty), $b)
  | _  => throw ()



@[sum_push]
theorem sum_pair {I X : Type _} [Add X] [Zero X] [Add Y] [Zero Y] [IndexType I]
    (f : I → X) (g : I → Y) :
    ∑ i, (f i, g i) = (∑ i, f i, ∑ i, g i) := sorry_proof

@[sum_pull]
theorem pair_sum {I X : Type _} [Add X] [Zero X] [Add Y] [Zero Y] [IndexType I]
    (f : I → X) (g : I → Y) :
    (∑ i, f i, ∑ i, g i) = ∑ i, (f i, g i) := sorry_proof


open IndexType in
@[rsimp guard I .notAppOf ``Fin]
theorem sum_linearize {I X : Type _} [Add X] [Zero X] [IndexType I] (f : I → X) :
    ∑ i, f i
    =
    ∑ i : Fin (size I), f (fromFin i) := by simp only [sum]; rw[reduce_linearize]



variable {I : Type*} [IndexType I]

section OnMonoid
variable [AddCommMonoid α]

@[add_pull, sum_push]
theorem sum_add_distrib (f g : I → α) : ∑ i , (f i + g i) = (∑ i, f i) + (∑ i, g i) := sorry_proof

@[add_push, sum_pull]
theorem add_sum (f g : I → α) : (∑ i, f i) + (∑ i, g i) = ∑ i , (f i + g i) := by simp only[add_pull]

end OnMonoid



section OnSemiring
variable [NonUnitalNonAssocSemiring α]

@[sum_pull, mul_push]
theorem sum_mul (f : I → α) (a : α) :
    (∑ i, f i) * a = ∑ i, f i * a := sorry_proof

@[sum_pull, mul_push]
theorem mul_sum (f : ι → α) (a : α) :
    a * ∑ i, f i = ∑ i, a * f i := sorry_proof

end OnSemiring