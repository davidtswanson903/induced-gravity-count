# Related work

GENERATED from `docs-src/docs/related-work.md` by `make docs`. Where each part of the count already stands in the literature, from the literature check made before any result here was framed.

**The question the check had to answer** was whether the net sign of the induced Newton constant for the Standard Model's own content had been computed before, and under which cutoff. As far as the check found, it had not been computed in this form; parts of it had, and each is credited below.

## The mechanism

- **[Sakharov1967]** proposed that Einstein's action is the change in the vacuum's one-loop action when space is curved: induced gravity.
- **[Visser2002]** reviews it in modern form, and gives the caution behind K3: with a regulator that is not Lorentz-invariant, an induced action's time and space derivative terms need not agree.
- **[AmatiVeneziano1981]** induce the gauge couplings as well as the gravitational one from the matter content.

## The sign, counted over species

- **[BrodaSzanecki2009]** is the closest earlier work, and has the net count already. Under a Planckian proper-time cutoff it weights each species as this repository does: a minimal scalar and a two-component (Weyl) fermion one each, and a gauge field with its ghosts minus four. With the Higgs doublet's four scalars, forty-five Weyl fermions and twelve gauge fields, its combination N₀ + N½ − 4N₁ equals one, the coefficient it reports as 1/12π. It notes that the black hole's geometric entropy carries the same combination, and calls the gauge fields' contribution disputable, since they are themselves induced. This repository takes the same weights as a cross-check (`data/species.yaml`). What it adds is the count's structure: the split into kinetic parts and insertions, the criterion and its margin, the cutoff condition K1 under which the weighting is six for every profile, the horizon count species by species, the corollaries, and machine-checked arithmetic. On the gauge fields: without them the count is larger, not negative, so condition K2 sets the margin, not the sign.
- **[Tanaka1996]** reaches "three generations or more" for attractive gravity, in supersymmetric models: vector multiplets induce a negative Newton constant and scalar multiplets a positive one. That is the precedent for the generation floor here, and the convergence on three is real. The count differs, though. Tanaka counts supersymmetric multiplets, not the Standard Model's chiral content through the heat kernel's coefficient, and has neither the least-content result, nor the bound on the Higgs coupling, nor the horizon cross-check.

## The cutoff

- **[Vassilevich2003]** gives the heat-kernel coefficients this repository imports, for a Laplace-type operator on a closed manifold.
- **[ChamseddineConnes1997]**'s spectral action also puts its cutoff in an operator, and expands it in heat-kernel coefficients weighted by moments of the profile, in four dimensions. **[vanSuijlekom2024]** and **[EcksteinIochum2018]** state that expansion in any dimension for profiles that are Laplace transforms, and **[EstradaGraciaBondiaVarilly1998]** for Schwartz profiles, with the sharp cutoff covered only in the Cesàro sense. This repository proves the expansion for proper-time profiles from the heat trace alone, and imports it for the others.
- **The integration-by-parts identity** between a profile's two moments, which makes the kinetic part and the insertion stand at one to six for every profile, was not found stated in any of these sources.

## The horizon count

- **[LarsenWilczek1996]** show that the quantum correction to black hole entropy and the renormalization of Newton's constant carry the same divergence: the proportionality between horizon entropy and the induced coupling that the horizon count checks.
- **[Kabat1995]** computes a gauge field's horizon entropy as its physical polarizations plus a contact term with the horizon, the source of the contact column here.
- **[DonnellyWall2015]** read that contact term as the entanglement entropy of edge modes. The coefficient is the same, only its reading differs, and the count uses only the coefficient.
- **[FrolovFursaevZelnikov1997]** write the horizon entropy in induced gravity as entanglement less contact terms, and fix the sign convention used here for the induced coupling.
- **[Solodukhin2011]** reviews the entanglement entropy of black holes, including both relations.

## References

{{referencesList}}
