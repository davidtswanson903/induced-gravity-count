import IGC.Weights
import Mathlib.Tactic.Linarith

/-!
# The criterion

Result 3. With a negative kinetic total and a positive insertion total, the count is
positive exactly when the insertion's weighting `ρ`, relative to the kinetic part,
exceeds `6 |K| / I`. Under K1 the weighting is the formula's own six, for every
profile (`Profile.weighting_eq_six`, `OneToSix.lean`).
-/

namespace IGC

open IGC.Generated

/-- **Result 3.** The sign turns on one ratio. Stated over any ordered field, so the
weighting `ρ` may be any real. -/
theorem criterion {F : Type*} [Field F] [LinearOrder F] [IsStrictOrderedRing F]
    (K I ρ : F) (hK : K < 0) (hI : 0 < I) :
    0 < K + ρ / 6 * I ↔ 6 * |K| / I < ρ := by
  rw [abs_of_neg hK, div_lt_iff₀ hI]
  constructor <;> intro h <;> linarith

/-- The weighting a content's insertion has to clear for its count to be positive. -/
def thresholdOf (b : Branch) : ℚ := 6 * |kineticTotal b| / insertionTotal b

/-- How far the formula's own six clears that threshold, as a fraction of six. -/
def marginOf (b : Branch) : ℚ := (6 - thresholdOf b) / 6

end IGC
