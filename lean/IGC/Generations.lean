import IGC.StandardModel
import Mathlib.Tactic.Linarith

/-!
# Generations, doublets and right-handed neutrinos

The corollaries. A content is built from its parts (`IGC.Generated.smContent g h nu`):
`g` generations, `h` Higgs doublets and `nu` right-handed neutrinos, with the Standard
Model's gauge group and its ghosts. Its net count is `15g + 4h + nu − 48`
(`net_smContent`), for every `g`, `h` and `nu`.

* **The floor.** With one doublet the count runs −44, −29, −14 and +1 for zero to three
  generations, and it is positive exactly from three generations on -- for every number
  of generations from three up, not only three: a floor, not a selection.
* **The least content.** Among contents of whole generations and Higgs doublets, the only
  one with count exactly +1 is three generations and one doublet; with a right-handed
  neutrino in each generation, no content has count +1.
* **Right-handed neutrinos.** With `n` added to the Standard Model the count is `1 + n`,
  so the sign holds for every `n`, and the margin rises with `n`.

Every statement ranges over all naturals; none is a finite search.
-/

namespace IGC

open IGC.Generated

theorem kinetic_smContent (g h nu : ℕ) :
    kineticTotal (smContent g h nu) = 4 * h - 2 * (15 * g + nu) + 24 := by
  norm_num [kineticTotal, sumBy, SpeciesRow.kinetic, smContent,
    minimalScalar, weylFermion, vector, ghost]
  ring

theorem insertion_smContent (g h nu : ℕ) :
    insertionTotal (smContent g h nu) = 3 * (15 * g + nu) - 72 := by
  norm_num [insertionTotal, sumBy, SpeciesRow.insertion, SpeciesRow.curvature, smContent,
    minimalScalar, weylFermion, vector, ghost]
  ring

/-- The net count of any content with this gauge group: `15g + 4h + nu − 48`. -/
theorem net_smContent (g h nu : ℕ) :
    netTotal (smContent g h nu) = 15 * g + 4 * h + nu - 48 := by
  rw [netTotal_eq_kinetic_add_insertion, kinetic_smContent, insertion_smContent]
  ring

/-! ### The floor -/

/-- With one doublet: −44, −29, −14 and +1 for zero to three generations. -/
theorem generation_counts :
    netTotal (smContent 0 1 0) = -44 ∧ netTotal (smContent 1 1 0) = -29 ∧
    netTotal (smContent 2 1 0) = -14 ∧ netTotal (smContent 3 1 0) = 1 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [net_smContent] <;> norm_num

/-- **The floor.** With one doublet, the count is positive exactly from three generations
on. -/
theorem generation_floor (g : ℕ) : 0 < netTotal (smContent g 1 0) ↔ 3 ≤ g := by
  rw [net_smContent]
  push_cast
  constructor
  · intro h
    by_contra hg
    have hg2 : (g : ℚ) ≤ 2 := by exact_mod_cast (by omega : g ≤ 2)
    linarith
  · intro hg
    have : (3 : ℚ) ≤ g := by exact_mod_cast hg
    linarith

/-! ### The least content -/

/-- **The least content.** Among contents of whole generations and Higgs doublets, the
count is exactly +1 only for three generations and one doublet. -/
theorem unique_count_one (g h : ℕ) : netTotal (smContent g h 0) = 1 ↔ g = 3 ∧ h = 1 := by
  rw [net_smContent]
  push_cast
  constructor
  · intro hq
    have h49 : ((15 * g + 4 * h : ℕ) : ℚ) = 49 := by push_cast; linarith
    have : 15 * g + 4 * h = 49 := by exact_mod_cast h49
    omega
  · rintro ⟨rfl, rfl⟩
    norm_num

/-- With a right-handed neutrino in each generation, no content has count +1: the count
`16g + 4h − 48` is a multiple of four. -/
theorem no_count_one_with_neutrinos (g h : ℕ) : netTotal (smContent g h g) ≠ 1 := by
  rw [net_smContent]
  intro hq
  have h49 : ((16 * g + 4 * h : ℕ) : ℚ) = 49 := by push_cast; linarith
  have : 16 * g + 4 * h = 49 := by exact_mod_cast h49
  omega

/-! ### Right-handed neutrinos -/

/-- Each right-handed neutrino adds one to the Standard Model's count. -/
theorem net_neutrinos (n : ℕ) : netTotal (smContent 3 1 n) = 1 + n := by
  rw [net_smContent]
  push_cast
  ring

/-- The margin with `n` right-handed neutrinos: `(1 + n)/(63 + 3n)`. -/
theorem margin_neutrinos (n : ℕ) :
    marginOf (smContent 3 1 n) = (1 + n) / (63 + 3 * n) := by
  have hn : (0 : ℚ) ≤ n := Nat.cast_nonneg n
  have hK : kineticTotal (smContent 3 1 n) = -62 - 2 * n := by
    rw [kinetic_smContent]; push_cast; ring
  have hI : insertionTotal (smContent 3 1 n) = 63 + 3 * n := by
    rw [insertion_smContent]; push_cast; ring
  have hd : (63 + 3 * (n : ℚ)) ≠ 0 := by positivity
  rw [marginOf, thresholdOf, hK, hI, abs_of_neg (by linarith)]
  field_simp
  ring

/-- The margin rises with every right-handed neutrino added. -/
theorem margin_neutrinos_lt {m n : ℕ} (h : m < n) :
    marginOf (smContent 3 1 m) < marginOf (smContent 3 1 n) := by
  rw [margin_neutrinos, margin_neutrinos, div_lt_div_iff₀ (by positivity) (by positivity)]
  have : (m : ℚ) < n := by exact_mod_cast h
  nlinarith

/-- With two right-handed neutrinos the margin is 1/23 ≈ 4.35 per cent. -/
theorem margin_two : marginOf branch2ExtraNeutrinos = 1 / 23 := by
  rw [show branch2ExtraNeutrinos = smContent 3 1 2 from rfl, margin_neutrinos]
  norm_num

/-- With three, 1/18 ≈ 5.56 per cent. -/
theorem margin_three : marginOf branch3ExtraNeutrinos = 1 / 18 := by
  rw [show branch3ExtraNeutrinos = smContent 3 1 3 from rfl, margin_neutrinos]
  norm_num

/-! ### As gravity -/

variable {s : ℝ}

/-- **The floor, as gravity.** With one doublet, under a profile whose expansion holds and
whose moment is positive, the content of `g` generations induces a Newton constant, and
every one it induces is positive -- gravity attracts -- exactly when `g ≥ 3`. -/
theorem generations_newton (bg : Background s) (hR : bg.intR ≠ 0) {f : ℝ → ℝ}
    (hf : ∀ x, SpectralActionA1 s (bg.spectrum x) (bg.heat x).a1 f)
    (hM : 0 < normalizedMoment s f) (g : ℕ) :
    (∃ κ, InducesNewton s (oneLoopAction bg f (contentOf (smContent g 1 0))) bg.intR κ) ∧
    ∀ κ, InducesNewton s (oneLoopAction bg f (contentOf (smContent g 1 0))) bg.intR κ →
      (0 < κ ↔ 3 ≤ g) ∧ ∀ L, 0 < L → (Attractive (newtonConstant s κ L) ↔ 3 ≤ g) := by
  have hf' : ∀ p ∈ contentOf (smContent g 1 0),
      SpectralActionA1 s (bg.spectrum p.1) (bg.heat p.1).a1 f := fun q _ => hf q.1
  refine ⟨⟨_, inducesNewton_of_spectralAction bg _ hf'⟩, fun κ hκ => ?_⟩
  have hiff : 0 < κ ↔ 3 ≤ g := by
    rw [inducesNewton_pos_iff bg hR _ hf' hM hκ, netWeight_contentOf, Rat.cast_pos,
      generation_floor]
  exact ⟨hiff, fun L hL => (attractive_iff hL).trans hiff⟩

/-- **The sign is robust to the neutrino content**: for every number of right-handed
neutrinos the induced Newton constant is positive and gravity attracts. -/
theorem neutrinos_newton_positive (bg : Background s) (hR : bg.intR ≠ 0) {f : ℝ → ℝ}
    (hf : ∀ x, SpectralActionA1 s (bg.spectrum x) (bg.heat x).a1 f)
    (hM : 0 < normalizedMoment s f) (n : ℕ) :
    (∃ κ, InducesNewton s (oneLoopAction bg f (contentOf (smContent 3 1 n))) bg.intR κ) ∧
    ∀ κ, InducesNewton s (oneLoopAction bg f (contentOf (smContent 3 1 n))) bg.intR κ →
      0 < κ ∧ ∀ L, 0 < L → Attractive (newtonConstant s κ L) :=
  newton_positive_of_net_pos bg hR _ (fun q _ => hf q.1) hM
    (by rw [netWeight_contentOf, net_neutrinos]; positivity)

end IGC
