import Mathlib.Analysis.SpecialFunctions.Pow.Integral

/-!
# Cutoff profiles, with their derivative as a measure

A cutoff profile need not be differentiable; the sharp step is the obvious example. What
every profile of bounded variation has is a derivative that is a measure, so a profile
here is written through that measure:

  `f(u) = m₊((u, ∞)) − m₋((u, ∞))`,  so that  `−f′ = m₊ − m₋`,

with `m₊` and `m₋` measures carried by `(0, ∞)`. A non-increasing profile has `m₋ = 0`;
the sharp step at `1` has `m₊ = δ₁`.

The count uses two moments of a profile:

* the **moment**, `∫₀^∞ f(u) u^(s−1) du`, which the kinetic part carries;
* the **derivative moment**, `−∫ u^s df = ∫ u^s d(m₊ − m₋)`, which the curvature
  insertion carries when it is taken as the first-order response of the cutoff trace
  (`OneToSix.lean`).

`Profile.derivativeMoment_eq` is the integration by parts between them,
`∫ u^s d(m₊ − m₋) = s ∫₀^∞ f(u) u^(s−1) du`, for every such profile and every `s > 0`.
It is the layer-cake formula, so it needs no derivative and no boundary term.
-/

namespace IGC

open MeasureTheory Set Filter Topology
open scoped ENNReal

/-- One side of a profile's derivative: a measure carried by `(0, ∞)`, with a finite
`s`-th moment. -/
structure TailMeasure (s : ℝ) where
  m : Measure ℝ
  null_Iic : m (Iic 0) = 0
  integrable_moment : Integrable (fun u => u ^ s) m

namespace TailMeasure

variable {s : ℝ}

/-- The tail `u ↦ m((u, ∞))`: a non-increasing profile whose derivative is `−m`. -/
noncomputable def tail (p : TailMeasure s) (u : ℝ) : ℝ := (p.m (Ioi u)).toReal

/-- No side of a profile at all. -/
noncomputable def zero (s : ℝ) : TailMeasure s :=
  ⟨0, congrFun Measure.coe_zero _, integrable_zero_measure⟩

theorem ae_pos (p : TailMeasure s) : ∀ᵐ u ∂p.m, 0 < u := by
  rw [ae_iff]
  refine measure_mono_null (fun u hu => ?_) p.null_Iic
  simp only [mem_ofPred_eq, not_lt] at hu
  exact hu

theorem lintegral_moment_ne_top (p : TailMeasure s) :
    ∫⁻ u, ENNReal.ofReal (u ^ s) ∂p.m ≠ ∞ := by
  rw [lintegral_ofReal_ne_top_iff_integrable p.integrable_moment.aestronglyMeasurable]
  · exact p.integrable_moment
  · filter_upwards [p.ae_pos] with u hu using Real.rpow_nonneg hu.le s

/-- Past any positive point the tail is finite (Markov). -/
theorem measure_Ioi_ne_top (p : TailMeasure s) (hs : 0 < s) {t : ℝ} (ht : 0 < t) :
    p.m (Ioi t) ≠ ∞ := by
  intro htop
  have hle := mul_meas_ge_le_lintegral₀ (μ := p.m)
    p.integrable_moment.aestronglyMeasurable.aemeasurable.ennreal_ofReal (ENNReal.ofReal (t ^ s))
  have hsub : Ioi t ⊆ {u | ENNReal.ofReal (t ^ s) ≤ ENNReal.ofReal (u ^ s)} := fun u hu =>
    ENNReal.ofReal_le_ofReal (Real.rpow_le_rpow ht.le (le_of_lt hu) hs.le)
  have hpos : ENNReal.ofReal (t ^ s) ≠ 0 := (ENNReal.ofReal_pos.2 (Real.rpow_pos_of_pos ht s)).ne'
  have htop' : p.m {u | ENNReal.ofReal (t ^ s) ≤ ENNReal.ofReal (u ^ s)} = ∞ :=
    top_unique (by rw [← htop]; exact measure_mono hsub)
  rw [htop', ENNReal.mul_top hpos] at hle
  exact p.lintegral_moment_ne_top (top_unique hle)

theorem measurable_measure_Ioi (p : TailMeasure s) : Measurable fun t : ℝ => p.m (Ioi t) :=
  Antitone.measurable fun _ _ hab => measure_mono (Ioi_subset_Ioi hab)

/-- The layer-cake formula, read for this measure. -/
theorem lintegral_eq (p : TailMeasure s) (hs : 0 < s) :
    ∫⁻ u, ENNReal.ofReal (u ^ s) ∂p.m =
      ENNReal.ofReal s * ∫⁻ t in Ioi 0, ENNReal.ofReal (p.tail t * t ^ (s - 1)) := by
  have hnn : 0 ≤ᵐ[p.m] fun u : ℝ => u := by
    filter_upwards [p.ae_pos] with u hu using hu.le
  have hcake := lintegral_rpow_eq_lintegral_meas_lt_mul p.m hnn aemeasurable_id' hs
  rw [hcake]
  congr 1
  apply setLIntegral_congr_fun measurableSet_Ioi
  intro t ht
  simp only [tail]
  rw [ENNReal.ofReal_mul ENNReal.toReal_nonneg,
    ENNReal.ofReal_toReal (p.measure_Ioi_ne_top hs ht)]
  rfl

theorem integrableOn_tail (p : TailMeasure s) (hs : 0 < s) :
    IntegrableOn (fun t => p.tail t * t ^ (s - 1)) (Ioi 0) := by
  have hmeas : AEStronglyMeasurable (fun t => p.tail t * t ^ (s - 1)) (volume.restrict (Ioi 0)) :=
    (p.measurable_measure_Ioi.ennreal_toReal.mul (by fun_prop)).aestronglyMeasurable
  rw [IntegrableOn, ← lintegral_ofReal_ne_top_iff_integrable hmeas]
  · intro htop
    have h := p.lintegral_eq hs
    rw [htop, ENNReal.mul_top (ENNReal.ofReal_pos.2 hs).ne'] at h
    exact p.lintegral_moment_ne_top h
  · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    exact mul_nonneg ENNReal.toReal_nonneg (Real.rpow_nonneg (le_of_lt ht) _)

/-- **The integration by parts, for one side**: `∫ u^s dm = s ∫₀^∞ m((t, ∞)) t^(s−1) dt`. -/
theorem integral_rpow_eq (p : TailMeasure s) (hs : 0 < s) :
    ∫ u, u ^ s ∂p.m = s * ∫ t in Ioi 0, p.tail t * t ^ (s - 1) := by
  have hL : ∫ u, u ^ s ∂p.m = (∫⁻ u, ENNReal.ofReal (u ^ s) ∂p.m).toReal := by
    apply integral_eq_lintegral_of_nonneg_ae
    · filter_upwards [p.ae_pos] with u hu using Real.rpow_nonneg hu.le s
    · exact p.integrable_moment.aestronglyMeasurable
  have hR : ∫ t in Ioi 0, p.tail t * t ^ (s - 1) =
      (∫⁻ t in Ioi 0, ENNReal.ofReal (p.tail t * t ^ (s - 1))).toReal := by
    apply integral_eq_lintegral_of_nonneg_ae
    · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      exact mul_nonneg ENNReal.toReal_nonneg (Real.rpow_nonneg (le_of_lt ht) _)
    · exact (p.integrableOn_tail hs).aestronglyMeasurable
  rw [hL, hR, p.lintegral_eq hs, ENNReal.toReal_mul, ENNReal.toReal_ofReal hs.le]

end TailMeasure

/-- **A cutoff profile** of bounded variation, through its derivative:
`f(u) = m₊((u, ∞)) − m₋((u, ∞))`. -/
structure Profile (s : ℝ) where
  pos : TailMeasure s
  neg : TailMeasure s

namespace Profile

variable {s : ℝ}

/-- The profile itself. -/
noncomputable def f (p : Profile s) (u : ℝ) : ℝ := p.pos.tail u - p.neg.tail u

/-- The moment the kinetic part carries: `∫₀^∞ f(u) u^(s−1) du`. -/
noncomputable def moment (p : Profile s) : ℝ := ∫ u in Ioi 0, p.f u * u ^ (s - 1)

/-- The derivative moment, `−∫ u^s df = ∫ u^s d(m₊ − m₋)`. -/
noncomputable def derivativeMoment (p : Profile s) : ℝ :=
  ∫ u, u ^ s ∂p.pos.m - ∫ u, u ^ s ∂p.neg.m

/-- The moment the insertion carries, on the same footing as the kinetic part's:
the derivative moment over `s`. -/
noncomputable def insertionMoment (p : Profile s) : ℝ := p.derivativeMoment / s

/-- **The integration by parts**, for every profile of bounded variation:
`∫ u^s d(m₊ − m₋) = s ∫₀^∞ f(u) u^(s−1) du`. -/
theorem derivativeMoment_eq (p : Profile s) (hs : 0 < s) :
    p.derivativeMoment = s * p.moment := by
  unfold derivativeMoment moment f
  simp_rw [sub_mul]
  rw [integral_sub (p.pos.integrableOn_tail hs) (p.neg.integrableOn_tail hs),
    p.pos.integral_rpow_eq hs, p.neg.integral_rpow_eq hs]
  ring

/-- The insertion's moment is the kinetic part's, for every profile. -/
theorem insertionMoment_eq (p : Profile s) (hs : 0 < s) : p.insertionMoment = p.moment := by
  rw [insertionMoment, derivativeMoment_eq p hs]
  field_simp

/-- A non-increasing profile: its derivative is one measure, with no second side. -/
noncomputable def ofMeasure (m : TailMeasure s) : Profile s := ⟨m, TailMeasure.zero s⟩

/-- A non-increasing profile that is not identically zero has a positive moment. -/
theorem moment_pos_ofMeasure (m : TailMeasure s) (hs : 0 < s) (hm : m.m ≠ 0) :
    0 < (ofMeasure m).moment := by
  have hIoi : 0 < m.m (Ioi 0) := by
    rw [pos_iff_ne_zero]
    intro h0
    apply hm
    rw [← Measure.measure_univ_eq_zero, ← Iic_union_Ioi (a := (0 : ℝ))]
    exact measure_union_null m.null_Iic h0
  have hd : 0 < (ofMeasure m).derivativeMoment := by
    unfold derivativeMoment
    simp only [ofMeasure, TailMeasure.zero, integral_zero_measure, sub_zero]
    rw [integral_pos_iff_support_of_nonneg_ae _ m.integrable_moment]
    · refine lt_of_lt_of_le hIoi (measure_mono fun u hu => ?_)
      exact (Real.rpow_pos_of_pos hu s).ne'
    · filter_upwards [m.ae_pos] with u hu using Real.rpow_nonneg hu.le s
  rw [derivativeMoment_eq _ hs] at hd
  exact pos_of_mul_pos_right hd hs.le

/-- The insertion's weighting against the kinetic part, in the units where the
formula's own is six: `6 · (insertion moment) / (moment)`. -/
noncomputable def weighting (p : Profile s) : ℝ := 6 * p.insertionMoment / p.moment

/-- **The weighting is six, for every profile.** -/
theorem weighting_eq_six (p : Profile s) (hs : 0 < s) (hm : p.moment ≠ 0) :
    p.weighting = 6 := by
  rw [weighting, insertionMoment_eq p hs]
  field_simp

theorem dirac_one_Iic_zero : Measure.dirac (1 : ℝ) (Iic 0) = 0 := by
  rw [Measure.dirac_apply' _ measurableSet_Iic]
  simp

theorem integrable_rpow_dirac_one (s : ℝ) : Integrable (fun u : ℝ => u ^ s) (Measure.dirac 1) :=
  integrable_dirac (by simp)

/-- The sharp cutoff at `1`: its derivative is minus the unit mass at `1`. -/
noncomputable def sharp (s : ℝ) : Profile s :=
  ofMeasure ⟨Measure.dirac 1, dirac_one_Iic_zero, integrable_rpow_dirac_one s⟩

/-- It is the step: one below the threshold, zero from it on. -/
theorem sharp_f (u : ℝ) : (sharp s).f u = if u < 1 then 1 else 0 := by
  simp only [f, sharp, ofMeasure, TailMeasure.tail, TailMeasure.zero,
    Measure.dirac_apply' _ measurableSet_Ioi, Measure.coe_zero, Pi.zero_apply,
    ENNReal.toReal_zero, sub_zero, Set.indicator_apply, mem_Ioi]
  split_ifs <;> simp

theorem sharp_derivativeMoment : (sharp s).derivativeMoment = 1 := by
  simp [derivativeMoment, sharp, ofMeasure, TailMeasure.zero, integral_dirac]

theorem sharp_moment (hs : 0 < s) : (sharp s).moment = 1 / s := by
  have h := derivativeMoment_eq (sharp s) hs
  rw [sharp_derivativeMoment] at h
  field_simp
  linarith

end Profile

end IGC
