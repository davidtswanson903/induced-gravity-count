import IGC.StandardModel
import Mathlib.Tactic.Linarith

/-!
# The horizon count

Result 5. The horizon entropy count is entanglement (each species' coefficient in the
horizon's entanglement entropy, in units of one real scalar) plus the contact term
(Kabat's, for a gauge field with its ghosts), both
cited in `data/species.yaml` independently of the weight formula. That this count
equals the induced one is the proportionality between horizon entropy and the induced
coupling (Larsen & Wilczek 1996), imported, not proved here.

What is proved: over any content drawn from the table, the two counts agree *exactly
when* every vector carries its two ghosts -- condition K2 -- and for the Standard Model
they read 73 and −72, net +1.
-/

namespace IGC

open IGC.Generated

/-- Entanglement: each species' entanglement coefficient, in units of one real scalar,
summed. -/
def entTotal (b : Branch) : ℚ := sumBy b fun r => (r.entanglement : ℚ)

/-- The contact term with the horizon, summed. -/
def conTotal (b : Branch) : ℚ := sumBy b fun r => (r.contact : ℚ)

/-- Every species in the content is one of the table's rows. -/
def FromTable (b : Branch) : Prop :=
  ∀ p ∈ b, p.1 = minimalScalar ∨ p.1 = weylFermion ∨ p.1 = vector ∨ p.1 = ghost

/-- The horizon count exceeds the induced count by one per ghost, less two per vector. -/
theorem horizon_sub_net (b : Branch) (hb : FromTable b) :
    entTotal b + conTotal b - netTotal b = (multOf b ghost : ℚ) - 2 * multOf b vector := by
  induction b with
  | nil => simp [entTotal, conTotal, netTotal, sumBy, multOf]
  | cons p b ih =>
    obtain ⟨r, m⟩ := p
    have ih := ih fun q hq => hb q (List.mem_cons_of_mem _ hq)
    have hr := hb (r, m) (by simp)
    simp only [entTotal, conTotal, netTotal, sumBy_cons, multOf_cons] at ih ⊢
    rcases hr with rfl | rfl | rfl | rfl <;>
      norm_num [SpeciesRow.weight, SpeciesRow.curvature,
        minimalScalar, weylFermion, vector, ghost] at ih ⊢ <;>
      linarith

/-- **Result 5, generally.** Over any content from the table, the horizon count equals
the induced count exactly when every vector carries its two ghosts. -/
theorem horizon_agrees_iff (b : Branch) (hb : FromTable b) :
    entTotal b + conTotal b = netTotal b ↔ GhostsPaired b := by
  have h := horizon_sub_net b hb
  unfold GhostsPaired
  constructor
  · intro heq
    have : (multOf b ghost : ℚ) = 2 * multOf b vector := by linarith
    exact_mod_cast this
  · intro hp
    have : (multOf b ghost : ℚ) = 2 * multOf b vector := by exact_mod_cast hp
    linarith

theorem fromTable_branch0 : FromTable branch0ExtraNeutrinos := by
  intro p hp
  simp only [branch0ExtraNeutrinos, smContent, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl | rfl <;> simp

/-- Entanglement: 73. -/
theorem sm_entanglement : entTotal branch0ExtraNeutrinos = 73 := by
  norm_num [entTotal, sumBy, branch0ExtraNeutrinos, smContent, minimalScalar, weylFermion, vector, ghost]

/-- The gauge fields' contact term: −72. -/
theorem sm_contact : conTotal branch0ExtraNeutrinos = -72 := by
  norm_num [conTotal, sumBy, branch0ExtraNeutrinos, smContent, minimalScalar, weylFermion, vector, ghost]

/-- **Results 4 and 5, jointly, over one content.** The kinetic parts sum to −62 and the
insertions to +63, net +1; the horizon count reads 73 and −72, and equals the net
because the content satisfies K2. Stated together so no two can be met by different
data. -/
theorem sm_count :
    kineticTotal branch0ExtraNeutrinos = -62 ∧
    insertionTotal branch0ExtraNeutrinos = 63 ∧
    netTotal branch0ExtraNeutrinos = 1 ∧
    entTotal branch0ExtraNeutrinos = 73 ∧
    conTotal branch0ExtraNeutrinos = -72 ∧
    entTotal branch0ExtraNeutrinos + conTotal branch0ExtraNeutrinos =
      netTotal branch0ExtraNeutrinos :=
  ⟨sm_kinetic, sm_insertion, sm_net, sm_entanglement, sm_contact,
    (horizon_agrees_iff _ fromTable_branch0).mpr gaugeFieldsCounted_branch0.2⟩

end IGC
