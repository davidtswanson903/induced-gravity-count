import IGC.StandardModel
import Mathlib.MeasureTheory.Integral.Gamma
import Mathlib.Analysis.SpecialFunctions.Gamma.BohrMollerup
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral

/-!
# The magnitude

The paper's claim is the sign. The magnitude of Newton's constant depends on the cutoff's
scale, and through it on the profile's shape, which enters only through its normalized
moment `M`. In four dimensions (`s = 1`) a content of net count `net` induces Newton's
constant `G` at cutoff scale `L = Λ²` exactly when `Λ² = 12π/(G M net)`
(`cutoff_for_newton`); with `G = 1/M_P²`, that is `Λ = M_P √(12π/(M net))`.

The range is reported over three standard profiles, each with its normalized moment in
closed form for every `s`:

* the sharp step, `1/Γ(s+1)` (`normalizedMoment_sharp`), which is `1` in four dimensions;
* the heat kernel's own profile `e^(−u)`, `1` (`normalizedMoment_heatKernel`);
* the Gaussian `e^(−u²)`, `Γ(s/2)/(2Γ(s))` (`normalizedMoment_gaussian`), which is `√π/2`
  in four dimensions.
-/

namespace IGC

open Real MeasureTheory Set
open IGC.Generated

/-- **The cutoff scale a Newton constant needs**, in four dimensions: the coefficient a
content of net count `net` induces under a profile of normalized moment `M` gives Newton's
constant `G` at cutoff scale `L = Λ²` exactly when `L = 12π/(G M net)`. -/
theorem cutoff_for_newton {M net G L : ℝ} (hM : 0 < M) (hnet : 0 < net) (hG : 0 < G)
    (hL : 0 < L) :
    newtonConstant 1 (M * (4 * π) ^ (-((1 : ℝ) + 1)) / 12 * net) L = G ↔
      L = 12 * π / (G * M * net) := by
  have hπ : 0 < π := pi_pos
  have h4 : (4 * π) ^ (-((1 : ℝ) + 1)) = 1 / (16 * π ^ 2) := by
    rw [show -((1 : ℝ) + 1) = -2 by norm_num, rpow_neg (by positivity), rpow_two]
    ring
  have key : newtonConstant 1 (M * (4 * π) ^ (-((1 : ℝ) + 1)) / 12 * net) L =
      12 * π / (M * net * L) := by
    rw [newtonConstant, rpow_one, h4]
    field_simp
  rw [key, div_eq_iff (by positivity), eq_div_iff (by positivity)]
  constructor <;> intro h <;> linarith

/-- The Standard Model, under any profile whose expansion holds and whose normalized moment
`M` is positive, induces Newton's constant `G` at cutoff scale `L = Λ²` exactly when
`Λ² = 12π/(G M)`. -/
theorem sm_cutoff_for_newton (bg : Background 1) (hR : bg.intR ≠ 0) {f : ℝ → ℝ}
    (hf : ∀ p ∈ contentOf branch0ExtraNeutrinos,
      SpectralActionA1 1 (bg.spectrum p.1) (bg.heat p.1).a1 f)
    (hM : 0 < normalizedMoment 1 f) {G L κ : ℝ} (hG : 0 < G) (hL : 0 < L)
    (hκ : InducesNewton 1 (oneLoopAction bg f (contentOf branch0ExtraNeutrinos)) bg.intR κ) :
    newtonConstant 1 κ L = G ↔ L = 12 * π / (G * normalizedMoment 1 f) := by
  rw [InducesNewton.unique hR hκ (inducesNewton_of_spectralAction bg _ hf),
    netWeight_contentOf, sm_net]
  have h := cutoff_for_newton hM one_pos hG hL
  simp only [Rat.cast_one, mul_one] at h ⊢
  exact h

/-- The sharp step's normalized moment: `1/Γ(s+1)`. -/
theorem normalizedMoment_sharp {s : ℝ} (hs : 0 < s) :
    normalizedMoment s (Profile.sharp s).f = 1 / Gamma (s + 1) := by
  have h := Profile.sharp_moment (s := s) hs
  unfold Profile.moment at h
  rw [normalizedMoment, h, Gamma_add_one hs.ne']
  field_simp

/-- The Gaussian profile's normalized moment: `Γ(s/2)/(2Γ(s))`. -/
theorem normalizedMoment_gaussian {s : ℝ} (hs : 0 < s) :
    normalizedMoment s (fun u => exp (-u ^ 2)) = Gamma (s / 2) / (2 * Gamma s) := by
  have h := integral_rpow_mul_exp_neg_rpow (p := 2) (q := s - 1) two_pos (by linarith)
  have hcongr : ∫ u in Ioi (0 : ℝ), exp (-u ^ 2) * u ^ (s - 1) =
      ∫ x in Ioi (0 : ℝ), x ^ (s - 1) * exp (-x ^ (2 : ℝ)) := by
    refine setIntegral_congr_fun measurableSet_Ioi fun u _ => ?_
    simp only [rpow_two]
    ring
  rw [normalizedMoment, hcongr, h, show (s - 1 + 1) / 2 = s / 2 by ring]
  field_simp

/-- In four dimensions the sharp step's normalized moment is `1`, the heat kernel's. -/
theorem normalizedMoment_sharp_four : normalizedMoment 1 (Profile.sharp 1).f = 1 := by
  rw [normalizedMoment_sharp one_pos, show (1 : ℝ) + 1 = 2 by norm_num, Gamma_two]
  norm_num

/-- In four dimensions the Gaussian's normalized moment is `√π/2`. -/
theorem normalizedMoment_gaussian_four :
    normalizedMoment 1 (fun u => exp (-u ^ 2)) = √π / 2 := by
  rw [normalizedMoment_gaussian one_pos, Gamma_one, Gamma_one_half_eq]
  ring

end IGC
