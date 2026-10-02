import IGC.Generations
import IGC.Coupling
import Mathlib.Tactic.Linarith

/-!
# What the count forbids, if gravity is induced

Two corollaries of the count that become constraints on content once Newton's constant is
taken to be entirely induced by the species below the cutoff. That premise is Sakharov's;
nothing here assumes or argues for it. Every statement is about the count, and about the
sign of the Newton constant a content induces.

* **Gauge bosons must be paid for.** A gauge vector with its two ghosts weighs −4 in the
  induced count, and so does its horizon count (`gauge_vector_cost`). A content of
  minimally coupled real scalars, Weyl fermions and gauge vectors, each vector with its
  ghosts, has count `scalars + Weyl − 4 · vectors` (`net_gaugeContent`), Broda and
  Szanecki's combination. The Standard Model extended by `b` gauge vectors, `k` scalars and
  `w` Weyl fermions has count `1 + k + w − 4b`, and induces attractive gravity exactly when
  `4b ≤ k + w` (`smExtension_pos_iff`, `extension_newton`). With one further gauge vector
  alone the count is −3; with a complex scalar to give it its mass, −1.
* **A conformally coupled Higgs doublet.** At the conformal coupling `ξ = 1/6` the
  Standard Model's count is −3 (`sm_conformal_net`), and no Newton constant it induces is
  positive (`sm_conformal_not_attractive`).
-/

namespace IGC

open IGC.Generated

/-- A content of `k` minimally coupled real scalars, `w` Weyl fermions and `v` gauge
vectors, each vector with its two ghosts. -/
def gaugeContent (k w v : ℕ) : Branch :=
  [(minimalScalar, k), (weylFermion, w), (vector, v), (ghost, 2 * v)]

/-- Every content with the Standard Model's gauge group is of this form. -/
theorem smContent_eq_gaugeContent (g h nu : ℕ) :
    smContent g h nu = gaugeContent (4 * h) (15 * g + nu) 12 := rfl

/-- **A gauge vector costs four, by either route.** In the induced count, its weight −2
and its two ghosts' −1 each; in the horizon count, its two polarizations and its contact
term −6, with nothing from its ghosts. -/
theorem gauge_vector_cost :
    vector.weight + 2 * ghost.weight = -4 ∧
    ((vector.entanglement + vector.contact : ℤ) : ℚ)
      + 2 * ((ghost.entanglement + ghost.contact : ℤ) : ℚ) = -4 := by
  norm_num [SpeciesRow.weight, SpeciesRow.curvature, vector, ghost]

/-- **Broda and Szanecki's combination.** Scalars and Weyl fermions count one each, and a
gauge vector with its ghosts minus four. -/
theorem net_gaugeContent (k w v : ℕ) :
    netTotal (gaugeContent k w v) = k + w - 4 * v := by
  norm_num [netTotal, sumBy, SpeciesRow.weight, SpeciesRow.curvature, gaugeContent,
    minimalScalar, weylFermion, vector, ghost]
  ring

/-- The Standard Model extended by `b` gauge vectors (each with its ghosts), `k` further
minimally coupled real scalars and `w` further Weyl fermions. -/
def smExtension (b k w : ℕ) : Branch := gaugeContent (4 + k) (45 + w) (12 + b)

/-- With nothing added, the extension is the Standard Model. -/
theorem smExtension_zero : smExtension 0 0 0 = branch0ExtraNeutrinos := rfl

theorem net_smExtension (b k w : ℕ) :
    netTotal (smExtension b k w) = 1 + k + w - 4 * b := by
  rw [smExtension, net_gaugeContent]
  push_cast
  ring

/-- **Gauge bosons must be paid for.** The extension's count is positive exactly when its
further scalars and Weyl fermions number at least four for each further gauge vector. -/
theorem smExtension_pos_iff (b k w : ℕ) :
    0 < netTotal (smExtension b k w) ↔ 4 * b ≤ k + w := by
  rw [net_smExtension]
  constructor
  · intro h
    have h' : ((4 * b : ℕ) : ℚ) < ((k + w + 1 : ℕ) : ℚ) := by push_cast; linarith
    have : 4 * b < k + w + 1 := by exact_mod_cast h'
    omega
  · intro h
    have h' : ((4 * b : ℕ) : ℚ) ≤ ((k + w : ℕ) : ℚ) := by exact_mod_cast h
    push_cast at h'
    linarith

/-- With one further gauge vector and nothing else, the count is −3. -/
theorem sm_plus_one_boson : netTotal (smExtension 1 0 0) = -3 := by
  rw [net_smExtension]
  norm_num

/-- With a complex scalar (two real scalars) added to give that vector its mass, −1. -/
theorem sm_plus_boson_and_scalars : netTotal (smExtension 1 2 0) = -1 := by
  rw [net_smExtension]
  norm_num

/-- **A conformally coupled Higgs doublet.** At `ξ = 1/6` the Standard Model's count is
−3. -/
theorem sm_conformal_net :
    netWeight (withScalarCoupling branch0ExtraNeutrinos (1 / 6)) = -3 := by
  rw [sm_higgs_net]
  norm_num

variable {s : ℝ}

/-- **Gauge bosons must be paid for, as gravity.** Under a profile whose expansion holds
and whose moment is positive, the extended content induces a Newton constant, and every
one it induces is positive -- gravity attracts -- exactly when `4b ≤ k + w`. -/
theorem extension_newton (bg : Background s) (hR : bg.intR ≠ 0) {f : ℝ → ℝ}
    (hf : ∀ x, SpectralActionA1 s (bg.spectrum x) (bg.heat x).a1 f)
    (hM : 0 < normalizedMoment s f) (b k w : ℕ) :
    (∃ κ, InducesNewton s (oneLoopAction bg f (contentOf (smExtension b k w))) bg.intR κ) ∧
    ∀ κ, InducesNewton s (oneLoopAction bg f (contentOf (smExtension b k w))) bg.intR κ →
      (0 < κ ↔ 4 * b ≤ k + w) ∧
        ∀ L, 0 < L → (Attractive (newtonConstant s κ L) ↔ 4 * b ≤ k + w) := by
  have hf' : ∀ p ∈ contentOf (smExtension b k w),
      SpectralActionA1 s (bg.spectrum p.1) (bg.heat p.1).a1 f := fun q _ => hf q.1
  refine ⟨⟨_, inducesNewton_of_spectralAction bg _ hf'⟩, fun κ hκ => ?_⟩
  have hiff : 0 < κ ↔ 4 * b ≤ k + w := by
    rw [inducesNewton_pos_iff bg hR _ hf' hM hκ, netWeight_contentOf, Rat.cast_pos,
      smExtension_pos_iff]
  exact ⟨hiff, fun L hL => (attractive_iff hL).trans hiff⟩

/-- **A conformally coupled Higgs doublet, as gravity.** With the doublet's four scalars at
`ξ = 1/6`, no Newton constant the Standard Model induces is positive, and none attracts. -/
theorem sm_conformal_not_attractive (bg : Background s) (hR : bg.intR ≠ 0) {f : ℝ → ℝ}
    (hf : ∀ x, SpectralActionA1 s (bg.spectrum x) (bg.heat x).a1 f)
    (hM : 0 < normalizedMoment s f) :
    ∀ κ, InducesNewton s
        (oneLoopAction bg f (withScalarCoupling branch0ExtraNeutrinos (1 / 6))) bg.intR κ →
      ¬ 0 < κ ∧ ∀ L, 0 < L → ¬ Attractive (newtonConstant s κ L) := by
  intro κ hκ
  have h := (sm_coupled_newton bg hR hf hM (1 / 6)).2 κ hκ
  have hn : ¬ ((1 : ℝ) / 6 < 1 / 24) := by norm_num
  exact ⟨fun hk => hn (h.1.mp hk), fun L hL hA => hn ((h.2 L hL).mp hA)⟩

end IGC
