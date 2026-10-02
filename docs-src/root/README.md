# induced-gravity-count

GENERATED from `docs-src/root/README.md` by `make docs`; every number below is read from `results/`.

**When induced gravity attracts.** In Sakharov's induced gravity the curvature term, and with it Newton's constant, arises from the one-loop vacuum energy of matter on a curved background. Whether the matter we have induces *attractive* gravity is a question of sign, and the sign is a count over species. This repository does that count exactly for the Standard Model:

> Under a spectral cutoff taken in the fluctuation operator itself, the Standard Model's induced Newton constant, with the Higgs minimally coupled, is positive. In units of one minimally coupled scalar, the kinetic parts sum to {{smKinetic}} and the curvature insertions to {{smInsertion}}, a net of {{smNet}}. The ratio between the two is one to six for every cutoff profile, so the sign does not depend on the profile. The horizon entropy count gives the same {{smNet}} by a second route: entanglement {{smEntanglement}}, and the gauge fields' contact term {{smContact}}.

The count is not new physics: it is Sakharov's mechanism with the Standard Model's own content, and parts of it are in the literature ([`docs/related-work.md`](docs/related-work.md)). What this repository offers is the count done exactly, with its conditions stated and its arithmetic and its central identities machine-checked in Lean.

## The conditions

The sign rests on four conditions, each stated openly:

{{conditionsTable}}

## The results

- **The criterion.** The count is positive exactly when the insertion's weighting exceeds {{smThreshold}} ≈ {{smThresholdDecimal}}. The cutoff of K1 gives six, for every profile, so the margin is {{smMarginPct}}.
- **The horizon count.** Entanglement {{smEntanglement}} and contact term {{smContact}}: net {{smNet}}, as the proportionality between horizon entropy and the induced coupling requires. The two counts agree species by species once every gauge field carries its two ghosts.
- **A floor on generations.** With the Standard Model's gauge group and one Higgs doublet, the count runs {{genCountZero}}, {{genCountOne}}, {{genCountTwo}} and {{genCountThree}} for zero to three generations, and it is positive for every number of generations from {{floorGenerationsSpelled}} on: a floor, not a selection.
- **The least content.** Among contents of whole generations and Higgs doublets, the only one whose count is exactly {{smNet}} is {{countOneGenerationsSpelled}} generations and {{countOneDoubletsSpelled}} doublet. With a right-handed neutrino in every generation, no content reaches it.
- **A bound on the Higgs coupling.** With the Higgs doublet's scalars at a common curvature coupling ξ, gravity attracts exactly when ξ < {{smCouplingBound}}.
- **The neutrino rows.** With two right-handed neutrinos the count is {{nuTwoNet}} and the margin {{nuTwoMarginPct}}; with three, {{nuThreeNet}} and {{nuThreeMarginPct}}. Each one adds one to the count, so the sign holds for any number.
- **If gravity is induced.** If Newton's constant is entirely induced by the species below the cutoff (Sakharov's premise, which this repository does not argue for), the count becomes a condition on content. A gauge boson with its two ghosts contributes {{weightGaugeField}} by either route, and a Weyl fermion or minimally coupled real scalar {{weightScalar}}, so the Standard Model with one further gauge boson alone has count {{smPlusOneBoson}}, and an extension attracts exactly when its new fields of these kinds number at least {{matterPerBosonSpelled}} per new gauge boson. A conformally coupled Higgs doublet gives {{smConformalCount}} and is excluded; Higgs inflation's coupling has the other sign and raises the count.

**What the count does not settle: the magnitude.** Newton's constant depends on the cutoff's scale, and through it on the profile's shape. In four dimensions the count induces Newton's constant at the cutoff Λ = M_P √(12π / (M · net)), with M the profile's moment against the heat kernel's. Over the sharp step, the heat kernel and the Gaussian, the Standard Model needs Λ from {{smCutoffLow}} to {{smCutoffHigh}} M_P. The claim is the sign, which does not move.

## How it is checked

| What | Where |
| --- | --- |
| Every species, with a citation for each entry | [`data/species.yaml`](data/species.yaml), [`data/references.yaml`](data/references.yaml) |
| The exact counts, the scan and the sensitivity | `src/igc/`, written to `results/` |
| The same counts, and the theorems, in Lean | `lean/IGC/`, over a table generated from the YAML |
| Python and Lean agree on every count | `lean/IGC/Agreement.lean`, which fails to build if they differ |
| Every claim, with its evidence and status | [`CLAIMS.md`](CLAIMS.md) |
| What is not established | [`LIMITS.md`](LIMITS.md) |

```
uv sync --extra dev          # or: pip install -e ".[dev]"
make data lean count scan sensitivity docs
make test
cd lean && lake env lean Audit.lean    # the axioms each cited theorem rests on
```

A reviewer with an afternoon should start at [`docs/reviewers-path.md`](docs/reviewers-path.md). Where this work came from is in [`PROVENANCE.md`](PROVENANCE.md).

## License

Code under the MIT license ([`LICENSE`](LICENSE)).
