import IGC.Generated.Table
import Mathlib.Tactic.Ring

/-!
# Each species' weight

A species contributes a kinetic part, its statistics sign times its components, and a
curvature insertion, minus six times its curvature trace with the same sign. Their sum
is its one-loop weight. Everything here is exact (`ℚ`), and every total is a sum over a
`Branch` from `IGC.Generated`, so all statements about a content read the same data.
-/

namespace IGC.Generated.SpeciesRow

/-- The curvature trace of the species' own operator, as a rational. -/
def curvature (r : SpeciesRow) : ℚ := (r.curvatureNum : ℚ) / r.curvatureDen

/-- The kinetic part: degrees of freedom with their statistics sign. -/
def kinetic (r : SpeciesRow) : ℚ := r.sign * r.components

/-- The curvature insertion: minus six times the curvature trace, with the statistics sign. -/
def insertion (r : SpeciesRow) : ℚ := -6 * r.curvature * r.sign

/-- The one-loop weight. -/
def weight (r : SpeciesRow) : ℚ := r.sign * (r.components - 6 * r.curvature)

/-- Result 1, per species: the weight is the kinetic part plus the insertion. -/
theorem weight_eq_kinetic_add_insertion (r : SpeciesRow) :
    r.weight = r.kinetic + r.insertion := by
  unfold weight kinetic insertion
  ring

end IGC.Generated.SpeciesRow

namespace IGC

open IGC.Generated

/-- `∑ multiplicity · f(row)` over a content. -/
def sumBy (b : Branch) (f : SpeciesRow → ℚ) : ℚ :=
  (b.map fun p => (p.2 : ℚ) * f p.1).sum

/-- The multiplicity a content gives one species. -/
def multOf (b : Branch) (r : SpeciesRow) : ℕ :=
  (b.map fun p => if p.1 = r then p.2 else 0).sum

def kineticTotal (b : Branch) : ℚ := sumBy b SpeciesRow.kinetic
def insertionTotal (b : Branch) : ℚ := sumBy b SpeciesRow.insertion
def netTotal (b : Branch) : ℚ := sumBy b SpeciesRow.weight

theorem sumBy_cons (r : SpeciesRow) (m : ℕ) (b : Branch) (f : SpeciesRow → ℚ) :
    sumBy ((r, m) :: b) f = m * f r + sumBy b f := by
  simp [sumBy]

theorem multOf_cons (r : SpeciesRow) (m : ℕ) (b : Branch) (x : SpeciesRow) :
    multOf ((r, m) :: b) x = (if r = x then m else 0) + multOf b x := by
  simp [multOf]

theorem sumBy_add (b : Branch) (f g : SpeciesRow → ℚ) :
    sumBy b (fun r => f r + g r) = sumBy b f + sumBy b g := by
  induction b with
  | nil => simp [sumBy]
  | cons p b ih =>
    obtain ⟨r, m⟩ := p
    rw [sumBy_cons, sumBy_cons, sumBy_cons, ih]
    ring

/-- Result 1, over a content: the net is the kinetic total plus the insertion total. -/
theorem netTotal_eq_kinetic_add_insertion (b : Branch) :
    netTotal b = kineticTotal b + insertionTotal b := by
  unfold netTotal kineticTotal insertionTotal
  rw [← sumBy_add]
  congr 1
  funext r
  exact SpeciesRow.weight_eq_kinetic_add_insertion r

end IGC
