import IGC.Weights

/-!
# The conditions

The count rests on four conditions. Where each enters the formal development:

* **K1, the cutoff** is spectral and taken in the fluctuation operator itself, with its
  profile normalized to the heat kernel's. Formally the regulated action
  (`oneLoopAction`, `InducedNewton.lean`) takes each species' cutoff trace over that
  species' own spectrum; a profile's normalization is its moment against the heat
  kernel's own (`normalizedMoment`, which is `1` for `e^(−u)`).
* **K2, the gauge fields** are counted as species at the cutoff, each vector with its two
  ghosts, so that each carries its contact term (`GaugeFieldsCounted`, below).
* **K3, the static coefficient only.** What is computed is the coefficient of `∫√g R` in
  the regulated Euclidean action on a fixed background, and nothing about an induced
  graviton sector's dynamics.
* **K4, the vacuum energy set aside.** The action's leading, cosmological term, at order
  `L^(s+1)`, is removed inside `HasA1Coeff` (`SpectralTrace.lean`) and never claimed.
-/

namespace IGC

open IGC.Generated

/-- Every vector carries its two ghosts. -/
def GhostsPaired (b : Branch) : Prop :=
  multOf b ghost = 2 * multOf b vector

/-- **K2.** The gauge fields are counted as species: present, each with its two
ghosts, so that each carries its contact term. -/
def GaugeFieldsCounted (b : Branch) : Prop :=
  0 < multOf b vector ∧ GhostsPaired b

instance (b : Branch) : Decidable (GhostsPaired b) :=
  inferInstanceAs (Decidable (_ = _))

instance (b : Branch) : Decidable (GaugeFieldsCounted b) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-- The Standard Model content counts its gauge fields as K2 requires. -/
theorem gaugeFieldsCounted_branch0 : GaugeFieldsCounted branch0ExtraNeutrinos := by
  decide

end IGC
