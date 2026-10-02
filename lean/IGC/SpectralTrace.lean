import Mathlib.Analysis.SpecialFunctions.Gamma.Basic

/-!
# The cutoff trace of an operator, and what is imported about it

An operator enters only through its spectrum: the measure `μ` that counts its eigenvalues
with multiplicity. Two traces are defined from it:

* the **heat trace** `Tr e^(−τD) = ∫ e^(−τλ) dμ(λ)`;
* the **cutoff trace** `Tr f(D/L) = ∫ f(λ/L) dμ(λ)`, for a profile `f` and a cutoff scale
  `L = Λ²`.

Two things are imported, both as hypotheses that theorems take, never as axioms:

* `HeatTrace`: the heat trace's small-τ expansion through order τ. For a Laplace-type
  operator on a closed manifold the expansion and its coefficients are Gilkey's
  (Vassilevich 2003, eqs. 2.21 and 4.26–4.27); which coefficients a species carries is
  fixed in `InducedNewton.lean`.
* `SpectralActionA1`: that a profile's cutoff trace has, at order `L^s`, the coefficient
  `(∫₀^∞ f(u) u^(s−1) du / Γ(s)) · a₁`. For the profiles of `ProperTime.lean` this is
  **proved** from `HeatTrace`, not assumed. For other profiles it is the spectral-action
  expansion as the literature states it: van Suijlekom, Prop. 9.7, and Eckstein–Iochum,
  Cor. 3.33, for Laplace-transform profiles; Estrada–Gracia-Bondía–Várilly for Schwartz
  profiles. For the sharp cutoff the expansion beyond the leading term holds only as a
  Cesàro mean, which this predicate does not express.

Here `s = d/2 − 1`, so `s = 1` in four dimensions.
-/

namespace IGC

open MeasureTheory Set Filter Topology Real

/-- The heat trace `Tr e^(−τD)` of an operator with spectral measure `μ`. -/
noncomputable def heatTrace (μ : Measure ℝ) (τ : ℝ) : ℝ := ∫ l, exp (-(τ * l)) ∂μ

/-- The cutoff trace `Tr f(D/L)` of an operator with spectral measure `μ`, under the
profile `f`, at cutoff scale `L = Λ²`. -/
noncomputable def spectralTrace (μ : Measure ℝ) (f : ℝ → ℝ) (L : ℝ) : ℝ :=
  ∫ l, f (l / L) ∂μ

/-- **Imported** (Vassilevich 2003, eq. 2.21): the heat trace of the operator exists for
every `τ > 0`, and near `τ = 0` it has the expansion
`τ^(s+1) Tr e^(−τD) = a₀ + a₁ τ + O(τ²)`. -/
structure HeatTrace (s : ℝ) (μ : Measure ℝ) where
  a0 : ℝ
  a1 : ℝ
  C : ℝ
  τ₀ : ℝ
  τ₀_pos : 0 < τ₀
  integrable : ∀ τ, 0 < τ → Integrable (fun l => exp (-(τ * l))) μ
  expansion : ∀ τ ∈ Ioc 0 τ₀, |τ ^ (s + 1) * heatTrace μ τ - a0 - a1 * τ| ≤ C * τ ^ 2

/-- `T` has the coefficient `c` at order `L^s`: once its leading `L^(s+1)` term is taken
off, `L^(−s) (T(L) − A L^(s+1)) → c`. The leading term is the cosmological one, which is
removed here and never claimed (K4). -/
def HasA1Coeff (s : ℝ) (T : ℝ → ℝ) (c : ℝ) : Prop :=
  ∃ A : ℝ, Tendsto (fun L => L ^ (-s) * (T L - A * L ^ (s + 1))) atTop (𝓝 c)

namespace HasA1Coeff

variable {s : ℝ} {T T₁ T₂ : ℝ → ℝ} {c c₁ c₂ : ℝ}

theorem rpow_neg_mul_rpow_succ (s : ℝ) {L : ℝ} (hL : 0 < L) : L ^ (-s) * L ^ (s + 1) = L := by
  rw [← rpow_add hL, show -s + (s + 1) = 1 by ring, rpow_one]

/-- The coefficient is unique. -/
theorem unique (h₁ : HasA1Coeff s T c₁) (h₂ : HasA1Coeff s T c₂) : c₁ = c₂ := by
  obtain ⟨A₁, h₁⟩ := h₁
  obtain ⟨A₂, h₂⟩ := h₂
  have hdiff : Tendsto (fun L : ℝ => (A₂ - A₁) * L) atTop (𝓝 (c₁ - c₂)) := by
    refine (h₁.sub h₂).congr' ?_
    filter_upwards [eventually_gt_atTop 0] with L hL
    have := rpow_neg_mul_rpow_succ s hL
    linear_combination (A₂ - A₁) * this
  have hA : A₁ = A₂ := by
    by_contra hne
    have hpos : 0 < (A₂ - A₁) ^ 2 := by
      have : A₂ - A₁ ≠ 0 := sub_ne_zero.2 (Ne.symm hne)
      positivity
    have htop : Tendsto (fun L : ℝ => (A₂ - A₁) * ((A₂ - A₁) * L)) atTop atTop := by
      simp_rw [← mul_assoc, ← sq]
      exact tendsto_id.const_mul_atTop hpos
    exact not_tendsto_nhds_of_tendsto_atTop htop _ (hdiff.const_mul (A₂ - A₁))
  subst hA
  exact tendsto_nhds_unique h₁ h₂

theorem add (h₁ : HasA1Coeff s T₁ c₁) (h₂ : HasA1Coeff s T₂ c₂) :
    HasA1Coeff s (fun L => T₁ L + T₂ L) (c₁ + c₂) := by
  obtain ⟨A₁, h₁⟩ := h₁
  obtain ⟨A₂, h₂⟩ := h₂
  refine ⟨A₁ + A₂, (h₁.add h₂).congr fun L => ?_⟩
  ring

theorem const_mul (r : ℝ) (h : HasA1Coeff s T c) : HasA1Coeff s (fun L => r * T L) (r * c) := by
  obtain ⟨A, h⟩ := h
  refine ⟨r * A, (h.const_mul r).congr fun L => ?_⟩
  ring

theorem zero : HasA1Coeff s (fun _ => 0) 0 :=
  ⟨0, tendsto_const_nhds.congr fun L => by ring⟩

/-- Only the large-`L` behaviour matters. -/
theorem congr_eventually (h : HasA1Coeff s T₁ c) (he : ∀ᶠ L in atTop, T₁ L = T₂ L) :
    HasA1Coeff s T₂ c := by
  obtain ⟨A, h⟩ := h
  refine ⟨A, h.congr' ?_⟩
  filter_upwards [he] with L hL
  rw [hL]

end HasA1Coeff

/-- A profile's moment against the heat kernel's own: `∫₀^∞ f(u) u^(s−1) du / Γ(s)`. It is
`1` for the heat kernel's profile `e^(−u)` (`normalizedMoment_heatKernel`); this is what
K1's "normalized to the heat kernel's" fixes. -/
noncomputable def normalizedMoment (s : ℝ) (f : ℝ → ℝ) : ℝ :=
  (∫ u in Ioi 0, f u * u ^ (s - 1)) / Gamma s

theorem normalizedMoment_heatKernel {s : ℝ} (hs : 0 < s) :
    normalizedMoment s (fun u => exp (-u)) = 1 := by
  rw [normalizedMoment, ← Gamma_eq_integral hs, div_self (Gamma_pos_of_pos hs).ne']

/-- **Imported for profiles outside `ProperTime.lean`'s class** (van Suijlekom, Prop. 9.7;
Eckstein–Iochum, Cor. 3.33; Estrada–Gracia-Bondía–Várilly): the profile's cutoff trace has,
at order `L^s`, the heat trace's `a₁` times the profile's normalized moment. -/
def SpectralActionA1 (s : ℝ) (μ : Measure ℝ) (a1 : ℝ) (f : ℝ → ℝ) : Prop :=
  HasA1Coeff s (spectralTrace μ f) (normalizedMoment s f * a1)

end IGC
