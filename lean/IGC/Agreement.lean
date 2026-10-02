import IGC.Horizon
import IGC.Coupling
import IGC.Extensions
import IGC.Generated.Expected

/-!
# Agreement between Lean and Python

For every branch and every quantity, Lean's own evaluation over the generated table
equals the value Python computed (`IGC.Generated.Expected`, generated from
`count.py`/`horizon.py`). If the two ever disagree, this file fails to build.
-/

namespace IGC

open IGC.Generated

/-- Exact evaluation over the generated table, checked by the kernel. -/
local macro "eval_count" : tactic => `(tactic|
  norm_num [kineticTotal, insertionTotal, netTotal, entTotal, conTotal, thresholdOf,
    couplingBoundOf, restOf, sumBy, multOf, SpeciesRow.kinetic, SpeciesRow.insertion,
    SpeciesRow.weight, SpeciesRow.curvature, minimalScalar, weylFermion, vector, ghost,
    branch0ExtraNeutrinos, branch2ExtraNeutrinos, branch3ExtraNeutrinos, smContent])

theorem agree_branch0 :
    kineticTotal branch0ExtraNeutrinos = Expected.kinetic0ExtraNeutrinos ∧
    insertionTotal branch0ExtraNeutrinos = Expected.insertion0ExtraNeutrinos ∧
    netTotal branch0ExtraNeutrinos = Expected.net0ExtraNeutrinos ∧
    thresholdOf branch0ExtraNeutrinos = Expected.threshold0ExtraNeutrinos ∧
    entTotal branch0ExtraNeutrinos = Expected.entanglement0ExtraNeutrinos ∧
    conTotal branch0ExtraNeutrinos = Expected.contact0ExtraNeutrinos ∧
    couplingBoundOf branch0ExtraNeutrinos = Expected.couplingBound0ExtraNeutrinos := by
  unfold Expected.kinetic0ExtraNeutrinos Expected.insertion0ExtraNeutrinos
    Expected.net0ExtraNeutrinos Expected.threshold0ExtraNeutrinos
    Expected.entanglement0ExtraNeutrinos Expected.contact0ExtraNeutrinos
    Expected.couplingBound0ExtraNeutrinos
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> eval_count

theorem agree_branch2 :
    kineticTotal branch2ExtraNeutrinos = Expected.kinetic2ExtraNeutrinos ∧
    insertionTotal branch2ExtraNeutrinos = Expected.insertion2ExtraNeutrinos ∧
    netTotal branch2ExtraNeutrinos = Expected.net2ExtraNeutrinos ∧
    thresholdOf branch2ExtraNeutrinos = Expected.threshold2ExtraNeutrinos ∧
    entTotal branch2ExtraNeutrinos = Expected.entanglement2ExtraNeutrinos ∧
    conTotal branch2ExtraNeutrinos = Expected.contact2ExtraNeutrinos ∧
    couplingBoundOf branch2ExtraNeutrinos = Expected.couplingBound2ExtraNeutrinos := by
  unfold Expected.kinetic2ExtraNeutrinos Expected.insertion2ExtraNeutrinos
    Expected.net2ExtraNeutrinos Expected.threshold2ExtraNeutrinos
    Expected.entanglement2ExtraNeutrinos Expected.contact2ExtraNeutrinos
    Expected.couplingBound2ExtraNeutrinos
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> eval_count

theorem agree_branch3 :
    kineticTotal branch3ExtraNeutrinos = Expected.kinetic3ExtraNeutrinos ∧
    insertionTotal branch3ExtraNeutrinos = Expected.insertion3ExtraNeutrinos ∧
    netTotal branch3ExtraNeutrinos = Expected.net3ExtraNeutrinos ∧
    thresholdOf branch3ExtraNeutrinos = Expected.threshold3ExtraNeutrinos ∧
    entTotal branch3ExtraNeutrinos = Expected.entanglement3ExtraNeutrinos ∧
    conTotal branch3ExtraNeutrinos = Expected.contact3ExtraNeutrinos ∧
    couplingBoundOf branch3ExtraNeutrinos = Expected.couplingBound3ExtraNeutrinos := by
  unfold Expected.kinetic3ExtraNeutrinos Expected.insertion3ExtraNeutrinos
    Expected.net3ExtraNeutrinos Expected.threshold3ExtraNeutrinos
    Expected.entanglement3ExtraNeutrinos Expected.contact3ExtraNeutrinos
    Expected.couplingBound3ExtraNeutrinos
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> eval_count

/-- The net count over zero to three generations with one doublet, as Python computes it. -/
theorem agree_generations :
    netTotal (smContent 0 1 0) = Expected.net0Generations ∧
    netTotal (smContent 1 1 0) = Expected.net1Generations ∧
    netTotal (smContent 2 1 0) = Expected.net2Generations ∧
    netTotal (smContent 3 1 0) = Expected.net3Generations := by
  unfold Expected.net0Generations Expected.net1Generations Expected.net2Generations
    Expected.net3Generations
  refine ⟨?_, ?_, ?_, ?_⟩ <;> eval_count

/-- The count with the Higgs doublet conformally coupled, `ξ = 1/6`, per branch, as Python
computes it. -/
theorem agree_conformal :
    netWithScalarCoupling branch0ExtraNeutrinos (1 / 6) =
      Expected.conformalCount0ExtraNeutrinos ∧
    netWithScalarCoupling branch2ExtraNeutrinos (1 / 6) =
      Expected.conformalCount2ExtraNeutrinos ∧
    netWithScalarCoupling branch3ExtraNeutrinos (1 / 6) =
      Expected.conformalCount3ExtraNeutrinos := by
  unfold Expected.conformalCount0ExtraNeutrinos Expected.conformalCount2ExtraNeutrinos
    Expected.conformalCount3ExtraNeutrinos
  refine ⟨?_, ?_, ?_⟩ <;> rw [netWithScalarCoupling_eq] <;> eval_count

/-- The Standard Model with one further gauge vector, alone and with a complex scalar, as
Python computes it, evaluated directly over the generated rows. -/
theorem agree_extensions :
    netTotal (smExtension 1 0 0) = Expected.netOneBoson ∧
    netTotal (smExtension 1 2 0) = Expected.netOneBosonAndScalars := by
  unfold Expected.netOneBoson Expected.netOneBosonAndScalars
  refine ⟨?_, ?_⟩ <;> norm_num [smExtension, gaugeContent, netTotal, sumBy,
    SpeciesRow.weight, SpeciesRow.curvature, minimalScalar, weylFermion, vector, ghost]

end IGC
