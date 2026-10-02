# induced-gravity-count

GENERATED from `docs-src/root/README.md` by `make docs`; every number below is read from `results/`.

**When induced gravity attracts.** In Sakharov's induced gravity the curvature term, and with it Newton's constant, arises from the one-loop vacuum energy of matter on a curved background. Whether the matter we have induces *attractive* gravity is a question of sign, and the sign is a count over species. This repository does that count exactly for the Standard Model:

> Under a spectral cutoff taken in the fluctuation operator itself, the Standard Model's induced Newton constant, with the Higgs minimally coupled, is positive. In units of one minimally coupled scalar, the kinetic parts sum to −62 and the curvature insertions to +63, a net of +1. The ratio between the two is one to six for every cutoff profile, so the sign does not depend on the profile. The horizon entropy count gives the same +1 by a second route: entanglement +73, and the gauge fields' contact term −72.

The count is not new physics: it is Sakharov's mechanism with the Standard Model's own content, and parts of it are in the literature ([`docs/related-work.md`](docs/related-work.md)). What this repository offers is the count done exactly, with its conditions stated and its arithmetic and its central identities machine-checked in Lean.

## The conditions

The sign rests on four conditions, each stated openly:

| | Condition | Why it matters |
| --- | --- | --- |
| **K1** | The cutoff is spectral, taken in the fluctuation operator, with its profile normalized to the heat kernel's | Under this cutoff the kinetic part and the curvature insertion stand at one to six for every profile. A cutoff taken in another operator transfers a share of that operator's curvature, and the ratio is lost |
| **K2** | One loop, with the gauge fields counted as species at the cutoff, each with its contact term | The contact term is what reconciles the induced coupling with horizon entropy |
| **K3** | The static coefficient only. The paper claims Newton's constant, not an induced graviton sector | With a regulator that is not Lorentz-invariant, an induced action's time and space derivative terms need not agree, so a dynamical claim would need more than a static one |
| **K4** | The vacuum energy is not addressed. The cosmological term is set aside, and the count concerns the curvature term alone | The cosmological term is the cutoff trace's leading order and the curvature term the next, so the count neither needs the vacuum energy nor says anything about it |

## The results

- **The criterion.** The count is positive exactly when the insertion's weighting exceeds 124/21 ≈ 5.905. The cutoff of K1 gives six, for every profile, so the margin is 1.59%.
- **The horizon count.** Entanglement +73 and contact term −72: net +1, as the proportionality between horizon entropy and the induced coupling requires. The two counts agree species by species once every gauge field carries its two ghosts.
- **A floor on generations.** With the Standard Model's gauge group and one Higgs doublet, the count runs −44, −29, −14 and +1 for zero to three generations, and it is positive for every number of generations from three on: a floor, not a selection.
- **The least content.** Among contents of whole generations and Higgs doublets, the only one whose count is exactly +1 is three generations and one doublet. With a right-handed neutrino in every generation, no content reaches it.
- **A bound on the Higgs coupling.** With the Higgs doublet's scalars at a common curvature coupling ξ, gravity attracts exactly when ξ < 1/24.
- **The neutrino rows.** With two right-handed neutrinos the count is +3 and the margin 4.35%; with three, +4 and 5.56%. Each one adds one to the count, so the sign holds for any number.
- **If gravity is induced.** If Newton's constant is entirely induced by the species below the cutoff (Sakharov's premise, which this repository does not argue for), the count becomes a condition on content. A gauge boson with its two ghosts contributes −4 by either route, and a Weyl fermion or minimally coupled real scalar +1, so the Standard Model with one further gauge boson alone has count −3, and an extension attracts exactly when its new fields of these kinds number at least four per new gauge boson. A conformally coupled Higgs doublet gives −3 and is excluded; Higgs inflation's coupling has the other sign and raises the count.

**What the count does not settle: the magnitude.** Newton's constant depends on the cutoff's scale, and through it on the profile's shape. In four dimensions the count induces Newton's constant at the cutoff Λ = M_P √(12π / (M · net)), with M the profile's moment against the heat kernel's. Over the sharp step, the heat kernel and the Gaussian, the Standard Model needs Λ from 6.140 to 6.522 M_P. The claim is the sign, which does not move.

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
