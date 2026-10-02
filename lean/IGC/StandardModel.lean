import IGC.InducedNewton
import IGC.Criterion

/-!
# The Standard Model's count

Result 4, and the headline. Every number is evaluated over
`IGC.Generated.branch0ExtraNeutrinos` -- the Standard Model's own content, generated
from `data/species.yaml` -- by exact rational arithmetic the kernel checks.

The headline (`sm_newton_positive`) puts the count into the induced action: on any
background with `∫√g R ≠ 0`, under any profile whose expansion holds and whose moment is
positive, the Standard Model with its Higgs minimally coupled induces a positive Newton
constant, and gravity attracts at every cutoff scale. For proper-time profiles nothing
about the profile is assumed (`sm_newton_positive_properTime`); for non-increasing
profiles, nothing about the moment (`sm_newton_positive_monotone`). With the Higgs
coupled to curvature, see `Coupling.lean`.

The Standard Model with right-handed neutrinos added, and with fewer or more generations
and doublets, is in `Generations.lean`.
-/

namespace IGC

open IGC.Generated

/-- Kinetic parts: −62. -/
theorem sm_kinetic : kineticTotal branch0ExtraNeutrinos = -62 := by
  norm_num [kineticTotal, sumBy, SpeciesRow.kinetic, branch0ExtraNeutrinos, smContent,
    minimalScalar, weylFermion, vector, ghost]

/-- Curvature insertions: +63. -/
theorem sm_insertion : insertionTotal branch0ExtraNeutrinos = 63 := by
  norm_num [insertionTotal, sumBy, SpeciesRow.insertion, SpeciesRow.curvature,
    branch0ExtraNeutrinos, smContent, minimalScalar, weylFermion, vector, ghost]

/-- The net count: +1. -/
theorem sm_net : netTotal branch0ExtraNeutrinos = 1 := by
  rw [netTotal_eq_kinetic_add_insertion, sm_kinetic, sm_insertion]
  norm_num

/-- The threshold is 124/21 ≈ 5.905, below the formula's six. -/
theorem sm_threshold : thresholdOf branch0ExtraNeutrinos = 124 / 21 := by
  rw [thresholdOf, sm_kinetic, sm_insertion]
  norm_num

/-- Six clears it by 1/63 of itself ≈ 1.59 per cent. -/
theorem sm_margin : marginOf branch0ExtraNeutrinos = 1 / 63 := by
  rw [marginOf, sm_threshold]
  norm_num

/-- **Result 3, for the Standard Model.** Its count, with the insertion weighted by any
real `ρ` against the formula's six, is positive exactly when `ρ` exceeds 124/21. -/
theorem sm_criterion_iff (ρ : ℝ) :
    0 < (kineticTotal branch0ExtraNeutrinos : ℝ) + ρ / 6 * (insertionTotal branch0ExtraNeutrinos : ℝ) ↔
      124 / 21 < ρ := by
  rw [criterion _ _ _ (by rw [sm_kinetic]; norm_num) (by rw [sm_insertion]; norm_num),
    sm_kinetic, sm_insertion]
  norm_num

variable {s : ℝ}

/-- **The headline.** On a background with `∫√g R ≠ 0`, with each species cut in its own
operator (K1) under a profile whose expansion holds and whose normalized moment is
positive, the Standard Model's regulated action -- its Higgs minimally coupled --
induces a Newton constant; every coefficient it induces is positive; and gravity
attracts at every cutoff scale. -/
theorem sm_newton_positive (bg : Background s) (hR : bg.intR ≠ 0) {f : ℝ → ℝ}
    (hf : ∀ p ∈ contentOf branch0ExtraNeutrinos,
      SpectralActionA1 s (bg.spectrum p.1) (bg.heat p.1).a1 f)
    (hM : 0 < normalizedMoment s f) :
    (∃ κ, InducesNewton s (oneLoopAction bg f (contentOf branch0ExtraNeutrinos)) bg.intR κ) ∧
    ∀ κ, InducesNewton s (oneLoopAction bg f (contentOf branch0ExtraNeutrinos)) bg.intR κ →
      0 < κ ∧ ∀ L, 0 < L → Attractive (newtonConstant s κ L) :=
  newton_positive_of_net_pos bg hR _ hf hM (by rw [netWeight_contentOf, sm_net]; norm_num)

/-- **The headline, for proper-time profiles**, with nothing about the profile assumed. -/
theorem sm_newton_positive_properTime (hs : 0 < s) (bg : Background s) (hR : bg.intR ≠ 0)
    (p : ProperTimeProfile s) :
    (∃ κ, InducesNewton s (oneLoopAction bg p.F (contentOf branch0ExtraNeutrinos)) bg.intR κ) ∧
    ∀ κ, InducesNewton s (oneLoopAction bg p.F (contentOf branch0ExtraNeutrinos)) bg.intR κ →
      0 < κ ∧ ∀ L, 0 < L → Attractive (newtonConstant s κ L) :=
  sm_newton_positive bg hR
    (fun q _ => by
      have := bg.sFinite q.1
      exact p.spectralActionA1 hs (bg.heat q.1))
    (p.normalizedMoment_pos hs)

/-- **The headline, for every non-increasing profile** whose expansion holds: no
hypothesis on its moment is needed. -/
theorem sm_newton_positive_monotone (hs : 0 < s) (bg : Background s) (hR : bg.intR ≠ 0)
    (m : TailMeasure s) (hm : m.m ≠ 0)
    (hf : ∀ p ∈ contentOf branch0ExtraNeutrinos,
      SpectralActionA1 s (bg.spectrum p.1) (bg.heat p.1).a1 (Profile.ofMeasure m).f) :
    (∃ κ, InducesNewton s (oneLoopAction bg (Profile.ofMeasure m).f
      (contentOf branch0ExtraNeutrinos)) bg.intR κ) ∧
    ∀ κ, InducesNewton s (oneLoopAction bg (Profile.ofMeasure m).f
      (contentOf branch0ExtraNeutrinos)) bg.intR κ →
      0 < κ ∧ ∀ L, 0 < L → Attractive (newtonConstant s κ L) :=
  sm_newton_positive bg hR hf (normalizedMoment_pos_ofMeasure hs m hm)

end IGC
