import IGC.StandardModel
import Mathlib.Tactic.Linarith

/-!
# The bound on the Higgs doublet's curvature coupling

A corollary of the count. Give the content's scalars a common curvature coupling `ξ`, so
each one's curvature trace is `ξ` instead of 0: its weight becomes `1 − 6ξ`, and the count
stays positive exactly while `ξ` stays below a bound fixed by the rest of the content.
For the Standard Model, whose four real scalars are the Higgs doublet, with the gauge
fields counted as species (K2 holds for `branch0ExtraNeutrinos`,
`gaugeFieldsCounted_branch0`), the count is `1 − 24ξ` for any real `ξ` (`sm_higgs_net`),
and the induced Newton constant is positive exactly below 1/24 (`sm_coupled_newton`). A
single scalar coupled alone would face a different bound: the common coupling is what
gives 1/24. The rational count (`sm_attraction_iff`, `couplingBoundOf`) is what the
Python side checks against.
-/

namespace IGC

open IGC.Generated

/-- The minimal scalar's weight with curvature coupling `ξ`. -/
def scalarWeight (ξ : ℚ) : ℚ := minimalScalar.sign * (minimalScalar.components - 6 * ξ)

/-- A content's net count with its scalars' curvature coupling set to `ξ`. -/
def netWithScalarCoupling (b : Branch) (ξ : ℚ) : ℚ :=
  sumBy b fun r => if r = minimalScalar then scalarWeight ξ else r.weight

theorem minimalScalar_weight : minimalScalar.weight = 1 := by
  norm_num [SpeciesRow.weight, SpeciesRow.curvature, minimalScalar]

theorem scalarWeight_eq (ξ : ℚ) : scalarWeight ξ = 1 - 6 * ξ := by
  norm_num [scalarWeight, minimalScalar]

/-- Everything in the content but its scalars. -/
def restOf (b : Branch) : ℚ := netTotal b - multOf b minimalScalar * minimalScalar.weight

theorem netWithScalarCoupling_eq (b : Branch) (ξ : ℚ) :
    netWithScalarCoupling b ξ = restOf b + multOf b minimalScalar * (1 - 6 * ξ) := by
  unfold restOf
  rw [minimalScalar_weight]
  induction b with
  | nil => simp [netWithScalarCoupling, netTotal, sumBy, multOf]
  | cons p b ih =>
    obtain ⟨r, m⟩ := p
    simp only [netWithScalarCoupling, netTotal, sumBy_cons, multOf_cons, scalarWeight_eq]
      at ih ⊢
    by_cases h : r = minimalScalar
    · subst h
      rw [ite_eq_left rfl, ite_eq_left rfl, minimalScalar_weight]
      push_cast
      linarith
    · rw [ite_eq_right h, ite_eq_right h]
      push_cast
      linarith

/-- The general form: the count `rest + s(1 − 6ξ)` is positive exactly below
`(rest + s) / 6s`. -/
theorem coupling_bound_general (s rest ξ : ℚ) (hs : 0 < s) :
    0 < rest + s * (1 - 6 * ξ) ↔ ξ < (rest + s) / (6 * s) := by
  rw [lt_div_iff₀ (by linarith)]
  constructor <;> intro h <;> linarith

/-- The largest coupling a content's scalars can carry with its count still positive. -/
def couplingBoundOf (b : Branch) : ℚ :=
  (restOf b + multOf b minimalScalar) / (6 * multOf b minimalScalar)

theorem coupling_bound (b : Branch) (hs : 0 < multOf b minimalScalar) (ξ : ℚ) :
    0 < netWithScalarCoupling b ξ ↔ ξ < couplingBoundOf b := by
  rw [netWithScalarCoupling_eq, couplingBoundOf]
  exact coupling_bound_general _ _ _ (by exact_mod_cast hs)

theorem sm_coupling_bound : couplingBoundOf branch0ExtraNeutrinos = 1 / 24 := by
  have h4 : multOf branch0ExtraNeutrinos minimalScalar = 4 := by decide
  rw [couplingBoundOf, restOf, sm_net, minimalScalar_weight, h4]
  norm_num

/-- **The corollary, as a count.** The Standard Model's count is positive exactly while
the Higgs doublet's common curvature coupling stays below 1/24. -/
theorem sm_attraction_iff (ξ : ℚ) :
    0 < netWithScalarCoupling branch0ExtraNeutrinos ξ ↔ ξ < 1 / 24 := by
  rw [coupling_bound _ (by decide) ξ, sm_coupling_bound]

/-- The minimal scalar given a real curvature coupling `ξ`: its operator's curvature
trace is `ξ`. -/
def scalarWithCoupling (ξ : ℝ) : Species := { toSpecies minimalScalar with curvature := ξ }

theorem scalarWithCoupling_weight (ξ : ℝ) : (scalarWithCoupling ξ).weight = 1 - 6 * ξ := by
  simp [Species.weight, scalarWithCoupling, toSpecies, minimalScalar]

/-- A content with every scalar given the common curvature coupling `ξ`, any real. -/
def withScalarCoupling (b : Branch) (ξ : ℝ) : Content :=
  b.map fun p => (if p.1 = minimalScalar then scalarWithCoupling ξ else toSpecies p.1, p.2)

theorem netWeight_withScalarCoupling (b : Branch) (ξ : ℝ) :
    netWeight (withScalarCoupling b ξ) =
      (restOf b : ℝ) + (multOf b minimalScalar : ℝ) * (1 - 6 * ξ) := by
  unfold restOf
  rw [minimalScalar_weight]
  induction b with
  | nil => simp [withScalarCoupling, netWeight, netTotal, sumBy, multOf]
  | cons p b ih =>
    obtain ⟨r, m⟩ := p
    have hnet : netTotal ((r, m) :: b) = m * r.weight + netTotal b := sumBy_cons r m b _
    have hc : withScalarCoupling ((r, m) :: b) ξ =
        (if r = minimalScalar then scalarWithCoupling ξ else toSpecies r, m) ::
          withScalarCoupling b ξ := rfl
    rw [hc, netWeight_cons, ih, hnet, multOf_cons]
    by_cases h : r = minimalScalar
    · subst h
      simp only [ite_true, scalarWithCoupling_weight, minimalScalar_weight]
      push_cast
      ring
    · simp only [h, ite_false, toSpecies_weight]
      push_cast
      ring

/-- **The Standard Model's count with its Higgs doublet coupled**: `1 − 24ξ`, for any
real `ξ`. -/
theorem sm_higgs_net (ξ : ℝ) : netWeight (withScalarCoupling branch0ExtraNeutrinos ξ) = 1 - 24 * ξ := by
  have h4 : multOf branch0ExtraNeutrinos minimalScalar = 4 := by decide
  rw [netWeight_withScalarCoupling, restOf, sm_net, minimalScalar_weight, h4]
  push_cast
  ring

variable {s : ℝ}

/-- **The corollary, as gravity.** With the Higgs doublet's four scalars at a common
curvature coupling `ξ`, any real, under a profile whose expansion holds and whose
normalized moment is positive, the Standard Model induces a Newton constant, and every one
it induces is positive -- gravity attracts -- exactly when `ξ < 1/24`. -/
theorem sm_coupled_newton (bg : Background s) (hR : bg.intR ≠ 0) {f : ℝ → ℝ}
    (hf : ∀ x, SpectralActionA1 s (bg.spectrum x) (bg.heat x).a1 f)
    (hM : 0 < normalizedMoment s f) (ξ : ℝ) :
    (∃ κ, InducesNewton s (oneLoopAction bg f (withScalarCoupling branch0ExtraNeutrinos ξ))
      bg.intR κ) ∧
    ∀ κ, InducesNewton s (oneLoopAction bg f (withScalarCoupling branch0ExtraNeutrinos ξ))
      bg.intR κ → (0 < κ ↔ ξ < 1 / 24) ∧
        ∀ L, 0 < L → (Attractive (newtonConstant s κ L) ↔ ξ < 1 / 24) := by
  have h := inducesNewton_of_spectralAction bg (withScalarCoupling branch0ExtraNeutrinos ξ)
    (fun q _ => hf q.1)
  refine ⟨⟨_, h⟩, fun κ hκ => ?_⟩
  have hκ' := InducesNewton.unique hR hκ h
  have hiff : 0 < κ ↔ ξ < 1 / 24 := by
    rw [hκ', mul_pos_iff_of_pos_left (newtonFactor_pos hM), sm_higgs_net]
    constructor <;> intro h <;> linarith
  exact ⟨hiff, fun L hL => (attractive_iff hL).trans hiff⟩

/-- The same, for proper-time profiles, with nothing about the profile assumed. -/
theorem sm_coupled_newton_properTime (hs : 0 < s) (bg : Background s) (hR : bg.intR ≠ 0)
    (p : ProperTimeProfile s) (ξ : ℝ) :
    (∃ κ, InducesNewton s (oneLoopAction bg p.F (withScalarCoupling branch0ExtraNeutrinos ξ))
      bg.intR κ) ∧
    ∀ κ, InducesNewton s (oneLoopAction bg p.F (withScalarCoupling branch0ExtraNeutrinos ξ))
      bg.intR κ → (0 < κ ↔ ξ < 1 / 24) ∧
        ∀ L, 0 < L → (Attractive (newtonConstant s κ L) ↔ ξ < 1 / 24) :=
  sm_coupled_newton bg hR
    (fun r => by
      have := bg.sFinite r
      exact p.spectralActionA1 hs (bg.heat r))
    (p.normalizedMoment_pos hs) ξ

end IGC
