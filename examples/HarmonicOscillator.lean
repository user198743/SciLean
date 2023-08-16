import SciLean.Core
import SciLean.Core.Approx.Basic
import SciLean.Core.FloatAsReal
import SciLean.Tactic.LetNormalize
import SciLean.Util.RewriteBy
import SciLean.Modules.DifferentialEquations.OdeSolve

open_notation_over_field Float

open SciLean

open ComplexConjugate
@[simp]
theorem asdf  (a : Float)
  : conj a = a := sorry


def H (m k : Float) (x p : Float) := (1/(2*m)) * p*p + k/2 * x*x

variable (m k : Float) (f : Float → Float)

#check ∂ f
#check ∇ x, f x
#check ∇ (x:=m), f x

#check (fun (t : Float) x p => ∇ (p':=p), H m k x p') rewrite_by
  unfold H
  ftrans; let_normalize; ring_nf

#check odeSolve (λ t (x,p) => (H t t x p, H t t x p))

approx solver (m k : Float) (steps : Nat)
  := odeSolve (λ t (x,p) => ( ∇ (p':=p), H m k x  p',
                             -∇ (x':=x), H m k x' p))
by
  -- Unfold Hamiltonian and compute gradients
  unfold H
  -- set_option trace.Meta.Tactic.fun_trans.rewrite true in
  

  -- -- Apply RK4 method
  -- rw [odeSolve_fixed_dt runge_kutta4_step]
  -- approx_limit steps; simp; intro steps';


def main : IO Unit := do

  let substeps := 1
  let m := 1.0
  let k := 10.0

  let Δt := 0.1
  let x₀ := 1.0
  let p₀ := 0.0
  let mut t := 0
  let mut (x,p) := (x₀, p₀)

  for _ in [0:50] do
  
    (x, p) := solver m k substeps t (x, p) (t+Δt)
    t += Δt

    -- print
    for (j : Nat) in [0:20] do
      if j < 10*(x+1) then
        IO.print "o"
    IO.println ""

-- #eval main
