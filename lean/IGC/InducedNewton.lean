import IGC.Conditions
import IGC.ProperTime
import IGC.Profile

/-!
# The induced Newton constant

A content's regulated one-loop action, with each species cut in its own operator (K1),
and the Newton constant it induces.

What is imported is the heat trace of each species' operator, with the coefficients the
heat kernel gives a Laplace-type operator (`Background`). What is defined is the sign
convention: the Euclidean action carries `−(1/16πG) ∫√g R`, so a content induces `κ`
when its action's coefficient at order `L^s` is `−κ ∫√g R`, and then `1/(16πG) = κ L^s`.
Gravity attracts when `G > 0`.

What is proved (`inducesNewton_of_spectralAction`): for any content and any profile whose
expansion holds, the induced coefficient is the profile's normalized moment, times
`(4π)^(−(s+1))/12`, times the content's net count. For proper-time profiles the expansion
is itself proved, so nothing about the profile is assumed (`inducesNewton_properTime`); and
every non-increasing profile has a positive moment (`normalizedMoment_pos_ofMeasure`).

A species here carries a real curvature trace, so a curvature coupling may take any real
value; the table's rows, whose traces are rational, are species through `toSpecies`.
-/

namespace IGC

open MeasureTheory Set Filter Topology Real
open IGC.Generated

/-- A species as the induced action reads it: its statistics sign, its field components,
and the trace of its operator's curvature term, as a multiple of `R`. -/
structure Species where
  sign : ℤ
  components : ℤ
  curvature : ℝ

/-- A species' one-loop weight, in units of one minimally coupled scalar. -/
def Species.weight (x : Species) : ℝ := x.sign * (x.components - 6 * x.curvature)

/-- A table row, read as a species. -/
def toSpecies (r : SpeciesRow) : Species := ⟨r.sign, r.components, (r.curvature : ℝ)⟩

theorem toSpecies_weight (r : SpeciesRow) : (toSpecies r).weight = (r.weight : ℝ) := by
  simp only [Species.weight, toSpecies, SpeciesRow.weight]
  push_cast
  ring

/-- A content: species with their multiplicities. -/
abbrev Content := List (Species × ℕ)

/-- A table content, read as a content of species. -/
def contentOf (b : Branch) : Content := b.map fun p => (toSpecies p.1, p.2)

/-- A content's net count: `Σ multiplicity · weight`. -/
noncomputable def netWeight (c : Content) : ℝ := (c.map fun p => (p.2 : ℝ) * p.1.weight).sum

theorem netWeight_cons (x : Species) (m : ℕ) (c : Content) :
    netWeight ((x, m) :: c) = m * x.weight + netWeight c := by
  simp [netWeight]

theorem netWeight_contentOf (b : Branch) : netWeight (contentOf b) = (netTotal b : ℝ) := by
  induction b with
  | nil => simp [netWeight, contentOf, netTotal, sumBy]
  | cons p b ih =>
    obtain ⟨r, m⟩ := p
    have hnet : netTotal ((r, m) :: b) = m * r.weight + netTotal b := sumBy_cons r m b _
    have hc : contentOf ((r, m) :: b) = (toSpecies r, m) :: contentOf b := rfl
    rw [hc, netWeight_cons, ih, hnet, toSpecies_weight]
    push_cast
    ring

variable {s : ℝ}

/-- **Imported** (Vassilevich 2003, eqs. 4.26–4.27; for the scalar's `1/6 − ξ`, Birrell &
Davies, ch. 6). A closed background with `∫√g R = intR`, and on it each species'
fluctuation operator, through its spectrum, with its heat trace expanded and its `a₁`
the heat kernel's own: `(4π)^(−(s+1)) (N/6 − c) ∫√g R` for a species of `N` components
whose operator's curvature term has trace `c R`. -/
structure Background (s : ℝ) where
  intR : ℝ
  spectrum : Species → Measure ℝ
  sFinite : ∀ x, SFinite (spectrum x)
  heat : ∀ x, HeatTrace s (spectrum x)
  a1_eq : ∀ x, (heat x).a1 =
    (4 * π) ^ (-(s + 1)) * ((x.components : ℝ) / 6 - x.curvature) * intR

/-- **The regulated one-loop action** of a content under the profile `f`, at cutoff scale
`L`: `W(L) = −½ Σ m σ Tr f(D/L)`, each species `D` its own operator (K1). This is
`½ Σ σ log det D` with the logarithm regulated by `f`. -/
noncomputable def oneLoopAction (bg : Background s) (f : ℝ → ℝ) (c : Content) (L : ℝ) : ℝ :=
  -(1 / 2) * (c.map fun p => (p.2 : ℝ) * (p.1.sign : ℝ) * spectralTrace (bg.spectrum p.1) f L).sum

/-- **The induced Newton constant**, in the Euclidean convention `W ⊃ −(1/16πG) ∫√g R`
(Frolov, Fursaev & Zelnikov 1997, eq. 2.10): the action `W` induces `κ` when its
coefficient at order `L^s` is `−κ ∫√g R`, so that `1/(16πG) = κ L^s`. -/
def InducesNewton (s : ℝ) (W : ℝ → ℝ) (intR κ : ℝ) : Prop :=
  HasA1Coeff s W (-(κ * intR))

/-- On a background with `∫√g R ≠ 0` the induced coefficient is unique. -/
theorem InducesNewton.unique {W : ℝ → ℝ} {intR κ₁ κ₂ : ℝ} (hR : intR ≠ 0)
    (h₁ : InducesNewton s W intR κ₁) (h₂ : InducesNewton s W intR κ₂) : κ₁ = κ₂ :=
  mul_right_cancel₀ hR (neg_inj.1 (HasA1Coeff.unique h₁ h₂))

/-- Newton's constant at cutoff scale `L`, from `1/(16πG) = κ L^s`. -/
noncomputable def newtonConstant (s κ L : ℝ) : ℝ := 1 / (16 * π * κ * L ^ s)

/-- Gravity attracts when Newton's constant is positive: the Newtonian potential between
masses `M` and `m` is `−G M m / r`. -/
def Attractive (G : ℝ) : Prop := 0 < G

/-- At every cutoff scale, gravity attracts exactly when the induced coefficient is
positive. -/
theorem attractive_iff {κ L : ℝ} (hL : 0 < L) : Attractive (newtonConstant s κ L) ↔ 0 < κ := by
  unfold Attractive newtonConstant
  have hLs : 0 < L ^ s := rpow_pos_of_pos hL s
  have h16 : (0 : ℝ) < 16 * π := by positivity
  constructor
  · intro h
    exact pos_of_mul_pos_right (pos_of_mul_pos_left (one_div_pos.1 h) hLs.le) h16.le
  · intro h
    exact one_div_pos.2 (mul_pos (mul_pos h16 h) hLs)

/-- The cutoff traces of a content, weighted by multiplicity and statistics sign, carry
at order `L^s` the profile's normalized moment times `(4π)^(−(s+1)) ∫√g R / 6` times the
net count. -/
theorem hasA1Coeff_sum (bg : Background s) {f : ℝ → ℝ} (c : Content)
    (hf : ∀ p ∈ c, SpectralActionA1 s (bg.spectrum p.1) (bg.heat p.1).a1 f) :
    HasA1Coeff s
      (fun L => (c.map fun p => (p.2 : ℝ) * (p.1.sign : ℝ) * spectralTrace (bg.spectrum p.1) f L).sum)
      (normalizedMoment s f * (4 * π) ^ (-(s + 1)) * bg.intR / 6 * netWeight c) := by
  induction c with
  | nil => simpa [netWeight] using (HasA1Coeff.zero (s := s))
  | cons p c ih =>
    obtain ⟨x, m⟩ := p
    have hr := hf (x, m) List.mem_cons_self
    have ih := ih fun q hq => hf q (List.mem_cons_of_mem _ hq)
    unfold SpectralActionA1 at hr
    have h := (hr.const_mul ((m : ℝ) * (x.sign : ℝ))).add ih
    convert h using 1
    · funext L
      simp only [List.map_cons, List.sum_cons]
    · rw [bg.a1_eq x, netWeight_cons, Species.weight]
      ring

/-- **The induced coefficient of any content**: the profile's normalized moment, times
`(4π)^(−(s+1))/12`, times the content's net count. -/
theorem inducesNewton_of_spectralAction (bg : Background s) {f : ℝ → ℝ} (c : Content)
    (hf : ∀ p ∈ c, SpectralActionA1 s (bg.spectrum p.1) (bg.heat p.1).a1 f) :
    InducesNewton s (oneLoopAction bg f c) bg.intR
      (normalizedMoment s f * (4 * π) ^ (-(s + 1)) / 12 * netWeight c) := by
  have h := (hasA1Coeff_sum bg c hf).const_mul (-(1 / 2))
  unfold InducesNewton
  convert h using 1
  · rfl
  · ring

/-- For a proper-time profile nothing about the profile is assumed: the expansion is
proved (`ProperTimeProfile.spectralActionA1`). -/
theorem inducesNewton_properTime (hs : 0 < s) (bg : Background s) (p : ProperTimeProfile s)
    (c : Content) :
    InducesNewton s (oneLoopAction bg p.F c) bg.intR
      (normalizedMoment s p.F * (4 * π) ^ (-(s + 1)) / 12 * netWeight c) :=
  inducesNewton_of_spectralAction bg c fun q _ => by
    have := bg.sFinite q.1
    exact p.spectralActionA1 hs (bg.heat q.1)

/-- Every non-increasing profile that is not identically zero has a positive normalized
moment. -/
theorem normalizedMoment_pos_ofMeasure (hs : 0 < s) (m : TailMeasure s) (hm : m.m ≠ 0) :
    0 < normalizedMoment s (Profile.ofMeasure m).f := by
  unfold normalizedMoment
  exact div_pos (Profile.moment_pos_ofMeasure m hs hm) (Gamma_pos_of_pos hs)

/-- The factor in front of the net count is positive whenever the profile's normalized
moment is. -/
theorem newtonFactor_pos {f : ℝ → ℝ} (hM : 0 < normalizedMoment s f) :
    0 < normalizedMoment s f * (4 * π) ^ (-(s + 1)) / 12 :=
  div_pos (mul_pos hM (rpow_pos_of_pos (by positivity) _)) (by norm_num)

/-- A content with a positive net count induces a positive Newton constant, and so
attracts, at every cutoff scale. -/
theorem newton_positive_of_net_pos (bg : Background s) (hR : bg.intR ≠ 0) {f : ℝ → ℝ}
    (c : Content) (hf : ∀ p ∈ c, SpectralActionA1 s (bg.spectrum p.1) (bg.heat p.1).a1 f)
    (hM : 0 < normalizedMoment s f) (hnet : 0 < netWeight c) :
    (∃ κ, InducesNewton s (oneLoopAction bg f c) bg.intR κ) ∧
    ∀ κ, InducesNewton s (oneLoopAction bg f c) bg.intR κ →
      0 < κ ∧ ∀ L, 0 < L → Attractive (newtonConstant s κ L) := by
  have h := inducesNewton_of_spectralAction bg c hf
  refine ⟨⟨_, h⟩, fun κ hκ => ?_⟩
  have hpos : 0 < κ := by
    rw [InducesNewton.unique hR hκ h]
    exact mul_pos (newtonFactor_pos hM) hnet
  exact ⟨hpos, fun L hL => (attractive_iff hL).2 hpos⟩

/-- With a positive moment, every coefficient a content induces is positive exactly when
its net count is: the profile cannot change the sign. -/
theorem inducesNewton_pos_iff (bg : Background s) (hR : bg.intR ≠ 0) {f : ℝ → ℝ}
    (c : Content) (hf : ∀ p ∈ c, SpectralActionA1 s (bg.spectrum p.1) (bg.heat p.1).a1 f)
    (hM : 0 < normalizedMoment s f) {κ : ℝ}
    (hκ : InducesNewton s (oneLoopAction bg f c) bg.intR κ) : 0 < κ ↔ 0 < netWeight c := by
  rw [InducesNewton.unique hR hκ (inducesNewton_of_spectralAction bg c hf),
    mul_pos_iff_of_pos_left (newtonFactor_pos hM)]

end IGC
