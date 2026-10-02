import IGC.SpectralTrace
import Mathlib.Analysis.Calculus.ParametricIntegral
import Mathlib.MeasureTheory.Integral.Prod

/-!
# Proper-time profiles: where the expansion is proved

A proper-time profile is a Laplace transform, `F(u) = ∫ e^(−tu) dν(t)`, of a finite
measure `ν` carried by a bounded proper-time interval `(0, T]`. This is the regulated
logarithm of every proper-time cutoff with an ultraviolet and an infrared end, and it
contains the heat kernel's own profile `e^(−u)` (`ν = δ₁`).

For these profiles nothing about the cutoff trace is imported. From the heat trace's
expansion alone (`HeatTrace`), the cutoff trace `Tr F(D/L)` is shown to carry, at order
`L^s`, exactly `a₁` times the profile's normalized moment (`spectralActionA1`). This is
the Abelian direction of the spectral-action expansion: the cutoff trace is the heat
trace averaged over proper time (Fubini), and the expansion passes through the average.

The two moments of `F` are computed exactly (Mellin): `∫ F u^(s−1) = Γ(s) ∫ t^(−s) dν` and
`−∫ F′ u^s = Γ(s+1) ∫ t^(−s) dν`. So for these profiles the integration by parts between
them is the Gamma function's own recursion, `Γ(s+1) = s Γ(s)`.
-/

namespace IGC

open MeasureTheory Set Filter Topology Real

/-- **A proper-time profile**: `F(u) = ∫ e^(−tu) dν(t)`, with `ν` a nonzero finite measure
carried by `(0, T]` whose `t^(−(s+1))` moment is finite. -/
structure ProperTimeProfile (s : ℝ) where
  ν : Measure ℝ
  T : ℝ
  T_pos : 0 < T
  isFiniteMeasure : IsFiniteMeasure ν
  null_compl : ν (Ioc 0 T)ᶜ = 0
  integrable_moment : Integrable (fun t => t ^ (-(s + 1))) ν
  ne_zero : ν ≠ 0

namespace ProperTimeProfile

variable {s : ℝ} (p : ProperTimeProfile s)

instance : IsFiniteMeasure p.ν := p.isFiniteMeasure

/-- The profile. -/
noncomputable def F (u : ℝ) : ℝ := ∫ t, exp (-(t * u)) ∂p.ν

/-- Its derivative (`hasDerivAt_F`). -/
noncomputable def F' (u : ℝ) : ℝ := ∫ t, -t * exp (-(t * u)) ∂p.ν

/-- The moment the kinetic part carries. -/
noncomputable def moment : ℝ := ∫ u in Ioi 0, p.F u * u ^ (s - 1)

/-- The derivative moment, `−∫₀^∞ F′(u) u^s du`. -/
noncomputable def derivativeMoment : ℝ := -∫ u in Ioi 0, p.F' u * u ^ s

theorem ae_mem : ∀ᵐ t ∂p.ν, t ∈ Ioc 0 p.T := by
  rw [ae_iff]
  exact p.null_compl

theorem integrable_rpow {k : ℝ} (hk : -(s + 1) ≤ k) : Integrable (fun t => t ^ k) p.ν := by
  refine Integrable.mono' (p.integrable_moment.const_mul (p.T ^ (k + (s + 1))))
    (measurable_id.pow_const k).aestronglyMeasurable ?_
  filter_upwards [p.ae_mem] with t ht
  rw [Real.norm_eq_abs, abs_of_nonneg (rpow_nonneg ht.1.le _)]
  calc t ^ k = t ^ (k + (s + 1)) * t ^ (-(s + 1)) := by
        rw [← rpow_add ht.1]; congr 1; ring
    _ ≤ p.T ^ (k + (s + 1)) * t ^ (-(s + 1)) :=
        mul_le_mul_of_nonneg_right (rpow_le_rpow ht.1.le ht.2 (by linarith))
          (rpow_nonneg ht.1.le _)

theorem integrable_exp (u : ℝ) : Integrable (fun t => exp (-(t * u))) p.ν := by
  refine Integrable.mono' (integrable_const (exp (p.T * |u|)))
    (by fun_prop : Measurable fun t : ℝ => exp (-(t * u))).aestronglyMeasurable ?_
  filter_upwards [p.ae_mem] with t ht
  rw [Real.norm_eq_abs, abs_of_pos (exp_pos _)]
  apply exp_le_exp.2
  calc -(t * u) ≤ |t * u| := neg_le_abs _
    _ = t * |u| := by rw [abs_mul, abs_of_pos ht.1]
    _ ≤ p.T * |u| := mul_le_mul_of_nonneg_right ht.2 (abs_nonneg _)

/-- `F′` is the derivative of `F`. -/
theorem hasDerivAt_F (u : ℝ) : HasDerivAt p.F (p.F' u) u := by
  show HasDerivAt (fun x => ∫ t, exp (-(t * x)) ∂p.ν) (∫ t, -t * exp (-(t * u)) ∂p.ν) u
  refine (hasDerivAt_integral_of_dominated_loc_of_deriv_le (μ := p.ν)
    (F := fun x t => exp (-(t * x))) (F' := fun x t => -t * exp (-(t * x)))
    (bound := fun _ => p.T * exp (p.T * (|u| + 1)))
    (Metric.ball_mem_nhds u one_pos)
    (Eventually.of_forall fun x =>
      (by fun_prop : Measurable fun t : ℝ => exp (-(t * x))).aestronglyMeasurable)
    (p.integrable_exp u)
    (by fun_prop : Measurable fun t : ℝ => -t * exp (-(t * u))).aestronglyMeasurable
    ?_ (integrable_const _) ?_).2
  · filter_upwards [p.ae_mem] with t ht x hx
    rw [Real.norm_eq_abs, abs_mul, abs_neg, abs_of_pos ht.1, abs_of_pos (exp_pos _)]
    have hx' : |x| ≤ |u| + 1 := by
      have h := Metric.mem_ball.1 hx
      rw [Real.dist_eq] at h
      linarith [abs_sub_abs_le_abs_sub x u]
    refine mul_le_mul ht.2 (exp_le_exp.2 ?_) (exp_pos _).le p.T_pos.le
    calc -(t * x) ≤ |t * x| := neg_le_abs _
      _ = t * |x| := by rw [abs_mul, abs_of_pos ht.1]
      _ ≤ p.T * (|u| + 1) := mul_le_mul ht.2 hx' (abs_nonneg _) p.T_pos.le
  · filter_upwards with t x _
    have h : HasDerivAt (fun y => -t * y) (-t) x := by
      simpa using (hasDerivAt_id x).const_mul (-t)
    convert h.exp using 1
    · funext y
      rw [neg_mul]
    · simp only [neg_mul]
      ring

/-- **Mellin**, with a weight: `∫₀^∞ (∫ g(t) e^(−tu) dν) u^(a−1) du = Γ(a) ∫ g(t) t^(−a) dν`. -/
theorem mellin {g : ℝ → ℝ} (hg : Measurable g) {a : ℝ} (ha : 0 < a)
    (hint : Integrable (fun t => g t * t ^ (-a)) p.ν) :
    ∫ u in Ioi 0, (∫ t, g t * exp (-(t * u)) ∂p.ν) * u ^ (a - 1) =
      Gamma a * ∫ t, g t * t ^ (-a) ∂p.ν := by
  have hinner : ∀ t, 0 < t → ∫ u in Ioi 0, exp (-(t * u)) * u ^ (a - 1) = Gamma a * t ^ (-a) := by
    intro t ht
    calc ∫ u in Ioi 0, exp (-(t * u)) * u ^ (a - 1)
        = ∫ u in Ioi 0, u ^ (a - 1) * exp (-(t * u)) := by
          refine integral_congr_ae (Eventually.of_forall fun u => ?_)
          simp only
          ring
      _ = Gamma a * t ^ (-a) := by
          rw [integral_rpow_mul_exp_neg_mul_Ioi ha ht, one_div, inv_rpow ht.le, ← rpow_neg ht.le]
          ring
  let f : ℝ → ℝ → ℝ := fun u t => g t * exp (-(t * u)) * u ^ (a - 1)
  have hmeas : AEStronglyMeasurable (Function.uncurry f) ((volume.restrict (Ioi 0)).prod p.ν) := by
    apply Measurable.aestronglyMeasurable
    exact ((hg.comp measurable_snd).mul (by fun_prop)).mul (measurable_fst.pow_const _)
  have hprod : Integrable (Function.uncurry f) ((volume.restrict (Ioi 0)).prod p.ν) := by
    rw [integrable_prod_iff' hmeas]
    constructor
    · filter_upwards [p.ae_mem] with t ht
      have hi : Integrable (fun u => exp (-(t * u)) * u ^ (a - 1)) (volume.restrict (Ioi 0)) :=
        Integrable.of_integral_ne_zero (by
          rw [hinner t ht.1]
          exact (mul_pos (Gamma_pos_of_pos ha) (rpow_pos_of_pos ht.1 _)).ne')
      refine (hi.const_mul (g t)).congr (Eventually.of_forall fun u => ?_)
      simp only [Function.uncurry, f]
      ring
    · refine (hint.norm.const_mul (Gamma a)).congr ?_
      filter_upwards [p.ae_mem] with t ht
      have hnorm : EqOn (fun u => ‖Function.uncurry f (u, t)‖)
          (fun u => |g t| * (exp (-(t * u)) * u ^ (a - 1))) (Ioi 0) := by
        intro u hu
        simp only [Function.uncurry, f, Real.norm_eq_abs, abs_mul, abs_of_pos (exp_pos _),
          abs_of_nonneg (rpow_nonneg (le_of_lt hu) _)]
        ring
      rw [setIntegral_congr_fun measurableSet_Ioi hnorm, integral_const_mul, hinner t ht.1,
        Real.norm_eq_abs, abs_mul, abs_of_nonneg (rpow_nonneg ht.1.le _)]
      ring
  calc ∫ u in Ioi 0, (∫ t, g t * exp (-(t * u)) ∂p.ν) * u ^ (a - 1)
      = ∫ u in Ioi 0, ∫ t, f u t ∂p.ν := by
        refine integral_congr_ae (Eventually.of_forall fun u => ?_)
        simp only [f]
        rw [integral_mul_const]
    _ = ∫ t, (∫ u in Ioi 0, f u t) ∂p.ν := integral_integral_swap hprod
    _ = ∫ t, Gamma a * (g t * t ^ (-a)) ∂p.ν := by
        refine integral_congr_ae ?_
        filter_upwards [p.ae_mem] with t ht
        simp only [f, mul_assoc]
        rw [integral_const_mul, hinner t ht.1]
        ring
    _ = Gamma a * ∫ t, g t * t ^ (-a) ∂p.ν := integral_const_mul _ _

theorem mul_rpow_neg_succ {t : ℝ} (ht : 0 < t) : t * t ^ (-(s + 1)) = t ^ (-s) := by
  have h := rpow_add ht 1 (-(s + 1))
  rw [rpow_one] at h
  rw [← h]
  congr 1
  ring

/-- The moment, exactly: `Γ(s) ∫ t^(−s) dν`. -/
theorem moment_eq (hs : 0 < s) : p.moment = Gamma s * ∫ t, t ^ (-s) ∂p.ν := by
  have h := p.mellin (g := fun _ => 1) measurable_const hs
    (by simpa using p.integrable_rpow (k := -s) (by linarith))
  simpa [moment, F] using h

/-- The derivative moment, exactly: `Γ(s+1) ∫ t^(−s) dν`. -/
theorem derivativeMoment_eq_gamma (hs : 0 < s) :
    p.derivativeMoment = Gamma (s + 1) * ∫ t, t ^ (-s) ∂p.ν := by
  have hint : Integrable (fun t => id t * t ^ (-(s + 1))) p.ν := by
    refine (p.integrable_rpow (k := -s) (by linarith)).congr ?_
    filter_upwards [p.ae_mem] with t ht
    rw [id, mul_rpow_neg_succ ht.1]
  have h := p.mellin measurable_id (by linarith : 0 < s + 1) hint
  have hF' : ∀ u, p.F' u = -∫ t, id t * exp (-(t * u)) ∂p.ν := by
    intro u
    rw [F', ← integral_neg]
    simp [neg_mul]
  have hcongr : ∫ t, id t * t ^ (-(s + 1)) ∂p.ν = ∫ t, t ^ (-s) ∂p.ν := by
    refine integral_congr_ae ?_
    filter_upwards [p.ae_mem] with t ht
    rw [id, mul_rpow_neg_succ ht.1]
  rw [show s + 1 - 1 = s by ring, hcongr] at h
  rw [derivativeMoment]
  simp_rw [hF', neg_mul, integral_neg, neg_neg]
  exact h

/-- **The integration by parts, for proper-time profiles**: `−∫ F′ u^s = s ∫ F u^(s−1)`.
Here it is the Gamma function's recursion. -/
theorem derivativeMoment_eq (hs : 0 < s) : p.derivativeMoment = s * p.moment := by
  rw [derivativeMoment_eq_gamma p hs, moment_eq p hs, Gamma_add_one hs.ne']
  ring

theorem normalizedMoment_eq (hs : 0 < s) : normalizedMoment s p.F = ∫ t, t ^ (-s) ∂p.ν := by
  have h := moment_eq p hs
  rw [moment] at h
  rw [normalizedMoment, h]
  field_simp [(Gamma_pos_of_pos hs).ne']

theorem integral_rpow_pos {k : ℝ} (hk : -(s + 1) ≤ k) : 0 < ∫ t, t ^ k ∂p.ν := by
  rw [integral_pos_iff_support_of_nonneg_ae _ (p.integrable_rpow hk)]
  · have h1 : p.ν univ ≤ p.ν (Ioc 0 p.T) := by
      calc p.ν univ = p.ν (Ioc 0 p.T ∪ (Ioc 0 p.T)ᶜ) := by rw [union_compl_self]
        _ ≤ p.ν (Ioc 0 p.T) + p.ν (Ioc 0 p.T)ᶜ := measure_union_le _ _
        _ = p.ν (Ioc 0 p.T) := by rw [p.null_compl, add_zero]
    refine lt_of_lt_of_le (Measure.measure_univ_pos.2 p.ne_zero) (h1.trans (measure_mono ?_))
    intro t ht
    exact (rpow_pos_of_pos ht.1 k).ne'
  · filter_upwards [p.ae_mem] with t ht using rpow_nonneg ht.1.le k

/-- The profile's normalized moment is positive. -/
theorem normalizedMoment_pos (hs : 0 < s) : 0 < normalizedMoment s p.F := by
  rw [p.normalizedMoment_eq hs]
  exact p.integral_rpow_pos (by linarith)

/-! ### The Abelian theorem -/

variable {μ : Measure ℝ}

/-- Near `τ = 0` the heat trace, scaled by `τ^(s+1)`, is bounded. -/
theorem heatTrace_bound (h : HeatTrace s μ) {τ : ℝ} (hτ : τ ∈ Ioc 0 h.τ₀) :
    |τ ^ (s + 1) * heatTrace μ τ| ≤ |h.a0| + |h.a1| * h.τ₀ + |h.C| * h.τ₀ ^ 2 := by
  have e := _root_.abs_le.1 (h.expansion τ hτ)
  have hτ2 : τ ^ 2 ≤ h.τ₀ ^ 2 := pow_le_pow_left₀ hτ.1.le hτ.2 2
  have hC : h.C * τ ^ 2 ≤ |h.C| * h.τ₀ ^ 2 :=
    (mul_le_mul_of_nonneg_right (le_abs_self _) (sq_nonneg τ)).trans
      (mul_le_mul_of_nonneg_left hτ2 (abs_nonneg _))
  have ha1 : |h.a1 * τ| ≤ |h.a1| * h.τ₀ := by
    rw [abs_mul, abs_of_pos hτ.1]
    exact mul_le_mul_of_nonneg_left hτ.2 (abs_nonneg _)
  have h0 := _root_.abs_le.1 (le_refl |h.a0|)
  have h1 := _root_.abs_le.1 ha1
  rw [_root_.abs_le]
  constructor <;> nlinarith [neg_abs_le h.a0, le_abs_self h.a0]

theorem integrable_heatTrace [SFinite μ] (h : HeatTrace s μ) {L : ℝ} (hL : 0 < L)
    (hLT : p.T / h.τ₀ ≤ L) : Integrable (fun t => heatTrace μ (t / L)) p.ν := by
  have hmeas : AEStronglyMeasurable (fun t => heatTrace μ (t / L)) p.ν := by
    have hf : AEStronglyMeasurable (fun z : ℝ × ℝ => exp (-(z.1 / L * z.2))) (p.ν.prod μ) :=
      (by fun_prop : Measurable fun z : ℝ × ℝ => exp (-(z.1 / L * z.2))).aestronglyMeasurable
    exact hf.integral_prod_right'
  set K := |h.a0| + |h.a1| * h.τ₀ + |h.C| * h.τ₀ ^ 2
  refine Integrable.mono' (p.integrable_moment.const_mul (K * L ^ (s + 1))) hmeas ?_
  filter_upwards [p.ae_mem] with t ht
  have hτ : t / L ∈ Ioc 0 h.τ₀ := by
    refine ⟨div_pos ht.1 hL, ?_⟩
    rw [div_le_iff₀ hL]
    have := (div_le_iff₀ h.τ₀_pos).1 hLT
    linarith [ht.2]
  have hb := heatTrace_bound h hτ
  have hpos : 0 < (t / L) ^ (s + 1) := rpow_pos_of_pos (div_pos ht.1 hL) _
  have hθ : heatTrace μ (t / L) = ((t / L) ^ (s + 1))⁻¹ * ((t / L) ^ (s + 1) * heatTrace μ (t / L)) := by
    field_simp
  rw [Real.norm_eq_abs, hθ, abs_mul, abs_inv, abs_of_pos hpos]
  have hinv : ((t / L) ^ (s + 1))⁻¹ = L ^ (s + 1) * t ^ (-(s + 1)) := by
    rw [div_rpow ht.1.le hL.le, rpow_neg ht.1.le]
    field_simp
  rw [hinv]
  calc L ^ (s + 1) * t ^ (-(s + 1)) * |(t / L) ^ (s + 1) * heatTrace μ (t / L)|
      ≤ L ^ (s + 1) * t ^ (-(s + 1)) * K :=
        mul_le_mul_of_nonneg_left hb (mul_nonneg (rpow_nonneg hL.le _) (rpow_nonneg ht.1.le _))
    _ = K * L ^ (s + 1) * t ^ (-(s + 1)) := by ring

/-- Fubini: the cutoff trace is the heat trace averaged over proper time. -/
theorem spectralTrace_eq [SFinite μ] (h : HeatTrace s μ) {L : ℝ} (hL : 0 < L)
    (hLT : p.T / h.τ₀ ≤ L) : spectralTrace μ p.F L = ∫ t, heatTrace μ (t / L) ∂p.ν := by
  let f : ℝ → ℝ → ℝ := fun l t => exp (-(t * (l / L)))
  have hmeas : AEStronglyMeasurable (Function.uncurry f) (μ.prod p.ν) :=
    (by fun_prop : Measurable fun z : ℝ × ℝ => exp (-(z.2 * (z.1 / L)))).aestronglyMeasurable
  have hprod : Integrable (Function.uncurry f) (μ.prod p.ν) := by
    rw [integrable_prod_iff' hmeas]
    constructor
    · filter_upwards [p.ae_mem] with t ht
      refine (h.integrable (t / L) (div_pos ht.1 hL)).congr (Eventually.of_forall fun l => ?_)
      simp only [Function.uncurry, f]
      ring_nf
    · refine (p.integrable_heatTrace h hL hLT).congr (Eventually.of_forall fun t => ?_)
      simp only [heatTrace, Function.uncurry, f, Real.norm_eq_abs, abs_of_pos (exp_pos _)]
      refine integral_congr_ae (Eventually.of_forall fun l => ?_)
      simp only
      ring_nf
  calc spectralTrace μ p.F L = ∫ l, ∫ t, f l t ∂p.ν ∂μ := rfl
    _ = ∫ t, ∫ l, f l t ∂μ ∂p.ν := integral_integral_swap hprod
    _ = ∫ t, heatTrace μ (t / L) ∂p.ν := by
        refine integral_congr_ae (Eventually.of_forall fun t => ?_)
        simp only [heatTrace, f]
        refine integral_congr_ae (Eventually.of_forall fun l => ?_)
        simp only
        ring_nf

/-- The error the expansion leaves at one proper time, at scale `L`. -/
theorem abs_error_le (h : HeatTrace s μ) {L t : ℝ} (hL : 0 < L) (ht : 0 < t)
    (hτ : t / L ∈ Ioc 0 h.τ₀) :
    |L ^ (-s) * heatTrace μ (t / L) - h.a0 * L * t ^ (-(s + 1)) - h.a1 * t ^ (-s)| ≤
      |h.C| * t ^ (1 - s) / L := by
  have key : L * t ^ (-(s + 1)) * (t / L) ^ (s + 1) = L ^ (-s) := by
    have h1 : L ^ (-s) = L / L ^ (s + 1) := by
      rw [show -s = 1 - (s + 1) by ring, rpow_sub hL, rpow_one]
    rw [h1, div_rpow ht.le hL.le, rpow_neg ht.le]
    have : 0 < t ^ (s + 1) := rpow_pos_of_pos ht _
    have : 0 < L ^ (s + 1) := rpow_pos_of_pos hL _
    field_simp
  have hE : L ^ (-s) * heatTrace μ (t / L) - h.a0 * L * t ^ (-(s + 1)) - h.a1 * t ^ (-s) =
      L * t ^ (-(s + 1)) * ((t / L) ^ (s + 1) * heatTrace μ (t / L) - h.a0 - h.a1 * (t / L)) := by
    have hts : t ^ (-s) = t * t ^ (-(s + 1)) := (mul_rpow_neg_succ (s := s) ht).symm
    rw [← key, hts]
    field_simp
  have h2 : t ^ (-(s + 1)) * t ^ 2 = t ^ (1 - s) := by
    rw [← rpow_two, ← rpow_add ht]
    congr 1
    ring
  have hLt : 0 < L * t ^ (-(s + 1)) := mul_pos hL (rpow_pos_of_pos ht _)
  rw [hE, abs_mul, abs_of_pos hLt]
  calc L * t ^ (-(s + 1)) * |(t / L) ^ (s + 1) * heatTrace μ (t / L) - h.a0 - h.a1 * (t / L)|
      ≤ L * t ^ (-(s + 1)) * (|h.C| * (t / L) ^ 2) := by
        refine mul_le_mul_of_nonneg_left ((h.expansion _ hτ).trans ?_) hLt.le
        exact mul_le_mul_of_nonneg_right (le_abs_self _) (sq_nonneg _)
    _ = |h.C| * (t ^ (-(s + 1)) * t ^ 2) / L := by
        field_simp
    _ = |h.C| * t ^ (1 - s) / L := by rw [h2]

/-- **The Abelian theorem.** For a proper-time profile, the cutoff trace of an operator
carries, at order `L^s`, exactly its heat trace's `a₁` times the profile's normalized
moment. Nothing about the profile or the cutoff trace is assumed: only the heat trace's
expansion. -/
theorem spectralActionA1 [SFinite μ] (hs : 0 < s) (h : HeatTrace s μ) :
    SpectralActionA1 s μ h.a1 p.F := by
  have i0 := p.integrable_rpow (k := -(s + 1)) le_rfl
  have i1 := p.integrable_rpow (k := -s) (by linarith)
  have i2 := p.integrable_rpow (k := 1 - s) (by linarith)
  unfold SpectralActionA1
  rw [p.normalizedMoment_eq hs]
  refine ⟨h.a0 * ∫ t, t ^ (-(s + 1)) ∂p.ν, ?_⟩
  rw [tendsto_iff_norm_sub_tendsto_zero]
  refine squeeze_zero' (g := fun L => |h.C| * (∫ t, t ^ (1 - s) ∂p.ν) / L)
    (Eventually.of_forall fun _ => norm_nonneg _) ?_
    (tendsto_const_nhds.div_atTop tendsto_id)
  filter_upwards [eventually_gt_atTop 0, eventually_ge_atTop (p.T / h.τ₀)] with L hL hLT
  have hθ := p.integrable_heatTrace h hL hLT
  rw [p.spectralTrace_eq h hL hLT]
  have hid : L ^ (-s) * ((∫ t, heatTrace μ (t / L) ∂p.ν) -
        h.a0 * (∫ t, t ^ (-(s + 1)) ∂p.ν) * L ^ (s + 1)) -
        (∫ t, t ^ (-s) ∂p.ν) * h.a1 =
      ∫ t, (L ^ (-s) * heatTrace μ (t / L) - h.a0 * L * t ^ (-(s + 1)) - h.a1 * t ^ (-s)) ∂p.ν := by
    have hA : Integrable (fun t => L ^ (-s) * heatTrace μ (t / L) -
        h.a0 * L * t ^ (-(s + 1))) p.ν := (hθ.const_mul _).sub (i0.const_mul _)
    rw [integral_sub hA (i1.const_mul _),
      integral_sub (hθ.const_mul _) (i0.const_mul _), integral_const_mul, integral_const_mul,
      integral_const_mul]
    have := HasA1Coeff.rpow_neg_mul_rpow_succ s hL
    linear_combination (-(h.a0 * ∫ t, t ^ (-(s + 1)) ∂p.ν)) * this
  rw [hid]
  have hg : Integrable (fun t => |h.C| * t ^ (1 - s) / L) p.ν := (i2.const_mul _).div_const _
  refine (norm_integral_le_of_norm_le hg ?_).trans_eq ?_
  · filter_upwards [p.ae_mem] with t ht
    rw [Real.norm_eq_abs]
    refine abs_error_le h hL ht.1 ⟨div_pos ht.1 hL, ?_⟩
    rw [div_le_iff₀ hL]
    have := (div_le_iff₀ h.τ₀_pos).1 hLT
    linarith [ht.2]
  · rw [integral_div, integral_const_mul]

end ProperTimeProfile

end IGC
