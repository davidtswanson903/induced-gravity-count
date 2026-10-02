import IGC.ProperTime
import IGC.Profile

/-!
# One to six, for every profile

Result 2. A species' operator is its kinetic operator `D₀` with a curvature term inserted.
Under a cut in the species' own operator (K1) there are two ways to read the curvature
coefficient, and this file shows they agree, whatever the profile:

* **the full operator.** The insertion shifts the spectrum, so the heat trace of
  `D₀ + δ` is `e^(−τδ)` times that of `D₀` (`HeatTrace.shift`): its `a₁` is
  `a₁(D₀) − δ a₀(D₀)`. Gilkey's curvature term is derived here for a constant
  insertion, not imported. The cutoff trace of `D₀ + δ` then carries the profile's own
  moment times that `a₁` (`ProperTimeProfile.spectralActionA1`).
* **kinetic part plus response.** The kinetic part is the cut in `D₀`, carrying the
  profile's moment. The insertion is the first-order response of the cutoff trace,
  `d/dδ Tr F((D₀ + δ)/L)`, which carries the profile's *derivative* moment
  (`response_hasA1Coeff`).

The two agree because the derivative moment, normalized, is the profile's own moment:
the integration by parts (`ProperTimeProfile.derivativeMoment_eq`; for every profile of
bounded variation, the sharp step included, `Profile.derivativeMoment_eq`). With the
kinetic operator's `a₁ = (N/6) ρ` and an insertion of curvature trace `c`, so that
`δ a₀ = c ρ`, the coefficient is the profile's moment times `(N − 6c)/6 · ρ`: the kinetic
part and the insertion stand at one to six for every profile (`one_to_six`).
-/

namespace IGC

open MeasureTheory Set Filter Topology Real

variable {s : ℝ} {μ : Measure ℝ}

/-- Inserting a constant term `δ` shifts the spectrum by `δ`, and multiplies the heat
trace by `e^(−τδ)`. -/
theorem heatTrace_map_add (δ τ : ℝ) :
    heatTrace (μ.map (· + δ)) τ = exp (-(τ * δ)) * heatTrace μ τ := by
  rw [heatTrace, integral_map (measurable_add_const δ).aemeasurable
    (by fun_prop : Measurable fun l : ℝ => exp (-(τ * l))).aestronglyMeasurable,
    heatTrace, ← integral_const_mul]
  refine integral_congr_ae (Eventually.of_forall fun l => ?_)
  simp only
  rw [← exp_add]
  ring_nf

namespace HeatTrace

theorem shift_τ₀_pos (h : HeatTrace s μ) (δ : ℝ) : 0 < min h.τ₀ (1 / (|δ| + 1)) :=
  lt_min h.τ₀_pos (by positivity)

theorem shift_integrable (h : HeatTrace s μ) (δ τ : ℝ) (hτ : 0 < τ) :
    Integrable (fun l => exp (-(τ * l))) (μ.map (· + δ)) := by
  rw [integrable_map_measure
    (by fun_prop : Measurable fun l : ℝ => exp (-(τ * l))).aestronglyMeasurable
    (measurable_add_const δ).aemeasurable]
  refine ((h.integrable τ hτ).const_mul (exp (-(τ * δ)))).congr
    (Eventually.of_forall fun l => ?_)
  simp only [Function.comp]
  rw [← exp_add]
  ring_nf

theorem shift_expansion (h : HeatTrace s μ) (δ : ℝ) :
    ∀ τ ∈ Ioc 0 (min h.τ₀ (1 / (|δ| + 1))),
      |τ ^ (s + 1) * heatTrace (μ.map (· + δ)) τ - h.a0 - (h.a1 - δ * h.a0) * τ| ≤
        (|h.a0| * δ ^ 2 + 2 * |h.a1| * |δ| + exp 1 * |h.C|) * τ ^ 2 := by
  intro τ hτ
  have hτ1 : τ ≤ h.τ₀ := hτ.2.trans (min_le_left _ _)
  have hτ2 : τ * (|δ| + 1) ≤ 1 := by
    have := hτ.2.trans (min_le_right _ _)
    rwa [le_div_iff₀ (by positivity)] at this
  have hx : |-(τ * δ)| ≤ 1 := by
    rw [abs_neg, abs_mul, abs_of_pos hτ.1]
    nlinarith [abs_nonneg δ, hτ.1]
  have e1 := Real.abs_exp_sub_one_sub_id_le hx
  have e2 := Real.abs_exp_sub_one_le hx
  have e3 : exp (-(τ * δ)) ≤ exp 1 := exp_le_exp.2 ((le_abs_self _).trans hx)
  have hr := h.expansion τ ⟨hτ.1, hτ1⟩
  rw [heatTrace_map_add]
  have hid : τ ^ (s + 1) * (exp (-(τ * δ)) * heatTrace μ τ) - h.a0 - (h.a1 - δ * h.a0) * τ =
      h.a0 * (exp (-(τ * δ)) - 1 - -(τ * δ)) + h.a1 * τ * (exp (-(τ * δ)) - 1) +
        exp (-(τ * δ)) * (τ ^ (s + 1) * heatTrace μ τ - h.a0 - h.a1 * τ) := by
    ring
  have t1 : |h.a0 * (exp (-(τ * δ)) - 1 - -(τ * δ))| ≤ |h.a0| * δ ^ 2 * τ ^ 2 := by
    rw [abs_mul]
    calc |h.a0| * |exp (-(τ * δ)) - 1 - -(τ * δ)| ≤ |h.a0| * (-(τ * δ)) ^ 2 :=
          mul_le_mul_of_nonneg_left e1 (abs_nonneg _)
      _ = |h.a0| * δ ^ 2 * τ ^ 2 := by ring
  have t2 : |h.a1 * τ * (exp (-(τ * δ)) - 1)| ≤ 2 * |h.a1| * |δ| * τ ^ 2 := by
    rw [abs_mul, abs_mul, abs_of_pos hτ.1]
    calc |h.a1| * τ * |exp (-(τ * δ)) - 1| ≤ |h.a1| * τ * (2 * |-(τ * δ)|) :=
          mul_le_mul_of_nonneg_left e2 (mul_nonneg (abs_nonneg _) hτ.1.le)
      _ = 2 * |h.a1| * |δ| * τ ^ 2 := by
          rw [abs_neg, abs_mul, abs_of_pos hτ.1]
          ring
  have t3 : |exp (-(τ * δ)) * (τ ^ (s + 1) * heatTrace μ τ - h.a0 - h.a1 * τ)| ≤
      exp 1 * |h.C| * τ ^ 2 := by
    rw [abs_mul, abs_of_pos (exp_pos _)]
    calc exp (-(τ * δ)) * |τ ^ (s + 1) * heatTrace μ τ - h.a0 - h.a1 * τ|
        ≤ exp 1 * (h.C * τ ^ 2) := mul_le_mul e3 hr (abs_nonneg _) (exp_pos 1).le
      _ ≤ exp 1 * (|h.C| * τ ^ 2) :=
          mul_le_mul_of_nonneg_left
            (mul_le_mul_of_nonneg_right (le_abs_self _) (sq_nonneg _)) (exp_pos 1).le
      _ = exp 1 * |h.C| * τ ^ 2 := by ring
  rw [hid]
  calc _ ≤ _ := abs_add_three _ _ _
    _ ≤ |h.a0| * δ ^ 2 * τ ^ 2 + 2 * |h.a1| * |δ| * τ ^ 2 + exp 1 * |h.C| * τ ^ 2 := by
        linarith
    _ = (|h.a0| * δ ^ 2 + 2 * |h.a1| * |δ| + exp 1 * |h.C|) * τ ^ 2 := by ring

/-- **The insertion's heat-kernel coefficient, derived.** The shifted operator's heat
trace has the same `a₀` and `a₁ − δ a₀`. -/
noncomputable def shift (h : HeatTrace s μ) (δ : ℝ) : HeatTrace s (μ.map (· + δ)) :=
  ⟨h.a0, h.a1 - δ * h.a0, |h.a0| * δ ^ 2 + 2 * |h.a1| * |δ| + exp 1 * |h.C|,
    min h.τ₀ (1 / (|δ| + 1)), shift_τ₀_pos h δ, shift_integrable h δ, shift_expansion h δ⟩

theorem shift_tau_ge (h : HeatTrace s μ) {δ : ℝ} (hδ : |δ| < 1) :
    min h.τ₀ (1 / 2) ≤ (h.shift δ).τ₀ := by
  refine min_le_min le_rfl ?_
  rw [div_le_div_iff₀ (by norm_num) (by positivity)]
  linarith

end HeatTrace

/-- The **response** of the cutoff trace to the inserted term: `d/dδ Tr f((D₀ + δ)/L)` at
`δ = 0`. -/
noncomputable def response (μ : Measure ℝ) (f : ℝ → ℝ) (L : ℝ) : ℝ :=
  deriv (fun δ => spectralTrace (μ.map (· + δ)) f L) 0

namespace ProperTimeProfile

variable (p : ProperTimeProfile s)

/-- The shifted operator's cutoff trace, averaged over proper time. -/
theorem spectralTrace_map_add [SFinite μ] (h : HeatTrace s μ) {δ L : ℝ} (hL : 0 < L)
    (hLT : p.T / (h.shift δ).τ₀ ≤ L) :
    spectralTrace (μ.map (· + δ)) p.F L =
      ∫ t, exp (-(t / L * δ)) * heatTrace μ (t / L) ∂p.ν := by
  rw [p.spectralTrace_eq (h.shift δ) hL hLT]
  simp_rw [heatTrace_map_add]

theorem T_div_le {τ₁ τ₂ L : ℝ} (hτ₁ : 0 < τ₁) (h12 : τ₁ ≤ τ₂) (hL : p.T / τ₁ ≤ L) :
    p.T / τ₂ ≤ L :=
  (div_le_div_of_nonneg_left p.T_pos.le hτ₁ h12).trans hL

/-- The response, computed: `−(1/L) ∫ t Tr e^(−(t/L) D₀) dν(t)`. -/
theorem hasDerivAt_spectralTrace_map_add [SFinite μ] (h : HeatTrace s μ) {L : ℝ} (hL : 0 < L)
    (hLT : p.T / min h.τ₀ (1 / 2) ≤ L) :
    HasDerivAt (fun δ => spectralTrace (μ.map (· + δ)) p.F L)
      (-(1 / L) * ∫ t, t * heatTrace μ (t / L) ∂p.ν) 0 := by
  have hτ₁ : 0 < min h.τ₀ (1 / 2) := lt_min h.τ₀_pos (by norm_num)
  have hθ : Integrable (fun t => heatTrace μ (t / L)) p.ν :=
    p.integrable_heatTrace h hL (p.T_div_le hτ₁ (min_le_left _ _) hLT)
  have hloc : (fun δ => spectralTrace (μ.map (· + δ)) p.F L) =ᶠ[𝓝 0]
      fun δ => ∫ t, exp (-(t / L * δ)) * heatTrace μ (t / L) ∂p.ν := by
    filter_upwards [Metric.ball_mem_nhds (0 : ℝ) one_pos] with δ hδ
    rw [Metric.mem_ball, Real.dist_eq, sub_zero] at hδ
    exact p.spectralTrace_map_add h hL (p.T_div_le hτ₁ (h.shift_tau_ge hδ) hLT)
  refine HasDerivAt.congr_of_eventuallyEq ?_ hloc
  have hd := (hasDerivAt_integral_of_dominated_loc_of_deriv_le (μ := p.ν)
    (F := fun δ t => exp (-(t / L * δ)) * heatTrace μ (t / L))
    (F' := fun δ t => -(t / L) * exp (-(t / L * δ)) * heatTrace μ (t / L)) (x₀ := 0)
    (bound := fun t => p.T / L * exp (p.T / L) * |heatTrace μ (t / L)|)
    (Metric.ball_mem_nhds 0 one_pos)
    (Eventually.of_forall fun δ =>
      (by fun_prop : Measurable fun t : ℝ => exp (-(t / L * δ))).aestronglyMeasurable.mul
        hθ.aestronglyMeasurable)
    (hθ.congr (Eventually.of_forall fun t => by simp))
    (((by fun_prop : Measurable fun t : ℝ => -(t / L) * exp (-(t / L * 0)))).aestronglyMeasurable.mul
      hθ.aestronglyMeasurable)
    ?_ (hθ.abs.const_mul _) ?_).2
  · convert hd using 1
    rw [← integral_const_mul]
    refine integral_congr_ae (Eventually.of_forall fun t => ?_)
    simp only [mul_zero, neg_zero, exp_zero, mul_one]
    ring
  · filter_upwards [p.ae_mem] with t ht x hx
    rw [Metric.mem_ball, Real.dist_eq, sub_zero] at hx
    have htL : 0 < t / L := div_pos ht.1 hL
    have htT : t / L ≤ p.T / L := div_le_div_of_nonneg_right ht.2 hL.le
    rw [Real.norm_eq_abs, abs_mul, abs_mul, abs_neg, abs_of_pos htL, abs_of_pos (exp_pos _)]
    refine mul_le_mul_of_nonneg_right (mul_le_mul htT (exp_le_exp.2 ?_) (exp_pos _).le
      (htL.le.trans htT)) (abs_nonneg _)
    calc -(t / L * x) ≤ |t / L * x| := neg_le_abs _
      _ = t / L * |x| := by rw [abs_mul, abs_of_pos htL]
      _ ≤ p.T / L * 1 := mul_le_mul htT hx.le (abs_nonneg _) (htL.le.trans htT)
      _ = p.T / L := mul_one _
  · filter_upwards with t x _
    have hlin : HasDerivAt (fun y => -(t / L) * y) (-(t / L)) x := by
      simpa using (hasDerivAt_id x).const_mul (-(t / L))
    convert hlin.exp.mul_const (heatTrace μ (t / L)) using 1
    · funext y
      simp only [neg_mul]
    · simp only [neg_mul]
      ring

/-- **The response carries the derivative moment.** At order `L^s` the response is
`−a₀ · (−∫ F′ u^s) / Γ(s+1)`. -/
theorem response_hasA1Coeff [SFinite μ] (hs : 0 < s) (h : HeatTrace s μ) :
    HasA1Coeff s (response μ p.F) (-(h.a0 * (p.derivativeMoment / Gamma (s + 1)))) := by
  have hτ₁ : 0 < min h.τ₀ (1 / 2) := lt_min h.τ₀_pos (by norm_num)
  have i1 := p.integrable_rpow (k := -s) (by linarith)
  have i2 := p.integrable_rpow (k := 1 - s) (by linarith)
  rw [p.derivativeMoment_eq_gamma hs, mul_div_cancel_left₀ _ (Gamma_pos_of_pos (by linarith)).ne']
  refine ⟨0, ?_⟩
  rw [tendsto_iff_norm_sub_tendsto_zero]
  set K := |h.C| * h.τ₀ + |h.a1|
  refine squeeze_zero' (g := fun L => K * (∫ t, t ^ (1 - s) ∂p.ν) / L)
    (Eventually.of_forall fun _ => norm_nonneg _) ?_
    (tendsto_const_nhds.div_atTop tendsto_id)
  filter_upwards [eventually_gt_atTop 0, eventually_ge_atTop (p.T / min h.τ₀ (1 / 2))]
    with L hL hLT
  have hLT' : p.T / h.τ₀ ≤ L := p.T_div_le hτ₁ (min_le_left _ _) hLT
  have hθ := p.integrable_heatTrace h hL hLT'
  have htθ : Integrable (fun t => t * heatTrace μ (t / L)) p.ν := by
    refine Integrable.mono' (hθ.abs.const_mul p.T) (by
      exact (measurable_id.aestronglyMeasurable.mul hθ.aestronglyMeasurable)) ?_
    filter_upwards [p.ae_mem] with t ht
    rw [Real.norm_eq_abs, abs_mul, abs_of_pos ht.1]
    exact mul_le_mul_of_nonneg_right ht.2 (abs_nonneg _)
  rw [response, (p.hasDerivAt_spectralTrace_map_add h hL hLT).deriv]
  have hid : L ^ (-s) * (-(1 / L) * (∫ t, t * heatTrace μ (t / L) ∂p.ν) - 0 * L ^ (s + 1)) -
      -(h.a0 * ∫ t, t ^ (-s) ∂p.ν) =
      -∫ t, (L ^ (-(s + 1)) * (t * heatTrace μ (t / L)) - h.a0 * t ^ (-s)) ∂p.ν := by
    rw [integral_sub (htθ.const_mul _) (i1.const_mul _), integral_const_mul, integral_const_mul]
    have hL1 : L ^ (-(s + 1)) = L ^ (-s) / L := by
      rw [show -(s + 1) = -s - 1 by ring, rpow_sub_one hL.ne']
    rw [hL1]
    field_simp
    ring
  rw [hid, norm_neg]
  have hg : Integrable (fun t => K * t ^ (1 - s) / L) p.ν := (i2.const_mul _).div_const _
  refine (norm_integral_le_of_norm_le hg ?_).trans_eq ?_
  · filter_upwards [p.ae_mem] with t ht
    have htL : t / L ∈ Ioc 0 h.τ₀ := by
      refine ⟨div_pos ht.1 hL, ?_⟩
      rw [div_le_iff₀ hL]
      have := (div_le_iff₀ h.τ₀_pos).1 hLT'
      linarith [ht.2]
    have hr := h.expansion _ htL
    have key : L ^ (-(s + 1)) * (t * heatTrace μ (t / L)) - h.a0 * t ^ (-s) =
        t ^ (-s) * ((t / L) ^ (s + 1) * heatTrace μ (t / L) - h.a0) := by
      have hts : t ^ (-s) = t * t ^ (-(s + 1)) := (mul_rpow_neg_succ (s := s) ht.1).symm
      rw [hts, div_rpow ht.1.le hL.le, rpow_neg ht.1.le, rpow_neg hL.le]
      have : 0 < t ^ (s + 1) := rpow_pos_of_pos ht.1 _
      have : 0 < L ^ (s + 1) := rpow_pos_of_pos hL _
      field_simp
    have hX : |(t / L) ^ (s + 1) * heatTrace μ (t / L) - h.a0| ≤ K * (t / L) := by
      have h1 : |(t / L) ^ (s + 1) * heatTrace μ (t / L) - h.a0| ≤
          |(t / L) ^ (s + 1) * heatTrace μ (t / L) - h.a0 - h.a1 * (t / L)| + |h.a1 * (t / L)| := by
        have := abs_add_le ((t / L) ^ (s + 1) * heatTrace μ (t / L) - h.a0 - h.a1 * (t / L))
          (h.a1 * (t / L))
        simpa using this
      have h2 : h.C * (t / L) ^ 2 ≤ |h.C| * h.τ₀ * (t / L) := by
        have hsq : (t / L) ^ 2 ≤ h.τ₀ * (t / L) := by
          rw [sq]
          exact mul_le_mul_of_nonneg_right htL.2 htL.1.le
        calc h.C * (t / L) ^ 2 ≤ |h.C| * (t / L) ^ 2 :=
              mul_le_mul_of_nonneg_right (le_abs_self _) (sq_nonneg _)
          _ ≤ |h.C| * (h.τ₀ * (t / L)) := mul_le_mul_of_nonneg_left hsq (abs_nonneg _)
          _ = |h.C| * h.τ₀ * (t / L) := by ring
      rw [abs_mul (h.a1), abs_of_pos htL.1] at h1
      calc _ ≤ _ := h1
        _ ≤ |h.C| * h.τ₀ * (t / L) + |h.a1| * (t / L) := by linarith
        _ = K * (t / L) := by ring
    rw [Real.norm_eq_abs, key, abs_mul, abs_of_pos (rpow_pos_of_pos ht.1 _)]
    calc t ^ (-s) * |(t / L) ^ (s + 1) * heatTrace μ (t / L) - h.a0|
        ≤ t ^ (-s) * (K * (t / L)) :=
          mul_le_mul_of_nonneg_left hX (rpow_nonneg ht.1.le _)
      _ = K * (t * t ^ (-s)) / L := by ring
      _ = K * t ^ (1 - s) / L := by
          congr 2
          have := rpow_add ht.1 1 (-s)
          rw [rpow_one] at this
          rw [← this]
          ring_nf
  · rw [integral_div, integral_const_mul]

/-- The derivative moment, normalized, is the profile's own moment. -/
theorem derivativeMoment_div_gamma (hs : 0 < s) :
    p.derivativeMoment / Gamma (s + 1) = normalizedMoment s p.F := by
  rw [p.derivativeMoment_eq_gamma hs, p.normalizedMoment_eq hs,
    mul_div_cancel_left₀ _ (Gamma_pos_of_pos (by linarith)).ne']

end ProperTimeProfile

/-- **Result 2: one to six, whatever the profile.** For a kinetic operator `D₀` whose heat
trace has `a₁ = (N/6) ρ`, and an inserted curvature term `δ` of curvature trace `c`
(`δ a₀ = c ρ`), under any proper-time profile:

1. the kinetic part, the cut in `D₀`, carries the profile's moment;
2. the insertion, as the first-order response, carries the derivative moment;
3. the derivative moment, normalized, is the profile's moment (integration by parts);
4. so the full operator's coefficient is the kinetic part plus `δ` times the response;
5. and it is the profile's moment times `(N − 6c)/6 · ρ`: one to six. -/
theorem one_to_six [SFinite μ] (hs : 0 < s) (h : HeatTrace s μ) (p : ProperTimeProfile s)
    {N c ρ δ : ℝ} (hkin : h.a1 = N / 6 * ρ) (hins : δ * h.a0 = c * ρ) :
    HasA1Coeff s (spectralTrace μ p.F) (normalizedMoment s p.F * (N / 6 * ρ)) ∧
    HasA1Coeff s (response μ p.F) (-(h.a0 * (p.derivativeMoment / Gamma (s + 1)))) ∧
    p.derivativeMoment / Gamma (s + 1) = normalizedMoment s p.F ∧
    HasA1Coeff s (spectralTrace (μ.map (· + δ)) p.F)
      (normalizedMoment s p.F * (N / 6 * ρ) + δ * -(h.a0 * (p.derivativeMoment / Gamma (s + 1)))) ∧
    normalizedMoment s p.F * (N / 6 * ρ) + δ * -(h.a0 * (p.derivativeMoment / Gamma (s + 1))) =
      normalizedMoment s p.F * ((N - 6 * c) / 6 * ρ) := by
  have hibp := p.derivativeMoment_div_gamma hs
  have hval : normalizedMoment s p.F * (N / 6 * ρ) +
      δ * -(h.a0 * (p.derivativeMoment / Gamma (s + 1))) =
      normalizedMoment s p.F * ((N - 6 * c) / 6 * ρ) := by
    rw [hibp]
    linear_combination (-(normalizedMoment s p.F)) * hins
  refine ⟨?_, p.response_hasA1Coeff hs h, hibp, ?_, hval⟩
  · rw [← hkin]
    exact p.spectralActionA1 hs h
  · have hfull := p.spectralActionA1 hs (h.shift δ)
    unfold SpectralActionA1 at hfull
    convert hfull using 1
    show _ = normalizedMoment s p.F * (h.a1 - δ * h.a0)
    rw [hibp, hkin]
    ring

end IGC
