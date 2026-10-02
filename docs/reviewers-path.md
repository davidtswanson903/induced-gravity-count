# A path for reviewers

GENERATED from `docs-src/docs/reviewers-path.md` by `make docs`. A route through this repository a careful reviewer can finish in an afternoon.

## 1. Read the species table (about 15 minutes)

[`data/species.yaml`](../data/species.yaml) holds every species the count reads, with its conventions stated at the top before any entry and a citation for every column. A species' weight is its statistics sign times its field components less six times its curvature trace. The Standard Model's content is entered by its parts: 12 gauge vectors with 2 ghosts each, 15 Weyl fermions per generation, 4 real scalars per Higgs doublet. Every content the repository counts is derived from those.

## 2. Run everything (about 10 minutes)

```
uv sync --extra dev
make data lean count scan sensitivity docs
make test
cd lean && lake env lean Audit.lean
```

The tests check every count against values frozen before the code was written, and the Lean build fails if Lean's evaluation of any count differs from Python's. The last command prints the axioms each cited theorem rests on: Lean's standard three, nothing else.

## 3. Read the Lean statements (about an hour)

Start with the statements, not the proofs:

- `lean/IGC/InducedNewton.lean`: the regulated one-loop action, with each species cut in its own operator, and the Newton constant it induces, with its sign convention.
- `lean/IGC/StandardModel.lean`: the headline, for every profile whose expansion holds, and with nothing assumed for proper-time profiles.
- `lean/IGC/OneToSix.lean` and `lean/IGC/Profile.lean`: why the profile cannot change the sign.
- `lean/IGC/Generations.lean`: the floor and the least content, for every number of generations and doublets.

## 4. Where to push hardest

**The cutoff condition, K1.** What is imported and what is proved:

- **Imported:** the heat trace's expansion and its first two coefficients, which are standard.
- **Proved here:** that each species' cutoff trace then carries the profile's moment times the curvature coefficient, for proper-time profiles.
- **Imported for other profiles:** the same statement for Laplace-transform and Schwartz profiles, which the literature states.
- **Only in the Cesàro sense:** the sharp cutoff ([`LIMITS.md`](../LIMITS.md)).

If you doubt the condition itself, that a cutoff belongs in the fluctuation operator, that is the place the sign could be contested.

**The species table's conventions.** The weight uses each species' covariant field components: a gauge field counts four. The horizon count uses a different column, each species' coefficient in the horizon's entanglement entropy in units of one real scalar: a gauge field's two polarizations count two, and a Weyl fermion counts one, though it has two physical degrees of freedom, since a fermion's degrees of freedom count half each. Only the gauge fields add a contact term. The two counts agree species by species only if both columns are right; check the table's citations.

## 5. The claims

[`CLAIMS.md`](../CLAIMS.md) lists every claim, its evidence, the Lean statements it cites and its status, with every correction to a claim's wording, with the original kept. If a summary of this repository states something not traceable to a row there, treat the summary as wrong.
