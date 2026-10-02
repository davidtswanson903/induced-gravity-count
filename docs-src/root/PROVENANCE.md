# Provenance

GENERATED from `docs-src/root/PROVENANCE.md` by `make docs`.

**Where the count came from.** It arose in work on a separate theory, the originating theory here, which needed the sign of the induced Newton constant for the Standard Model's own content. Nothing in this repository depends on that theory: the count is Sakharov's mechanism with the Standard Model's content, stated in existing physics.

**What came from there, and how it is used.** Only two things:

- **The question:** the sign of the induced Newton constant for the Standard Model.
- **Target values,** frozen in `tests/fixtures/` before the code that reproduces them was written: the counts {{smKinetic}}, {{smInsertion}} and {{smNet}}, the generation counts, the least content, and one value of the cutoff scale. They are equivalence targets, checked on every run, never inputs.

**What was written fresh.** Every line of code, every Lean statement and proof, and the species table with a citation for each entry. Where this repository and the originating computation differ, this repository's result stands and the difference is stated:

- **The magnitude.** The range is computed here in four dimensions over standard profiles; the originating range is not carried over.
- **The wording.** Several of the claims' first wordings were corrected where a check showed them wrong or overstated. Each correction keeps the original wording, in [`CLAIMS.md`](CLAIMS.md).
- **The profile family.** A numerical check of the insertion's weighting on a family of profiles is replaced by the exact result: the weighting is six for every profile of bounded variation.

**The literature check** came before any result was framed, and fixed how each is positioned: [`docs/related-work.md`](docs/related-work.md).

**Toolchains.** Lean and Mathlib are pinned in `lean/lean-toolchain` and `lean/lake-manifest.json`; Python's dependencies in `uv.lock`. Every generated file, Lean's table included, is regenerated from `data/` and `results/`, and a test fails if a committed copy differs from a fresh one.
