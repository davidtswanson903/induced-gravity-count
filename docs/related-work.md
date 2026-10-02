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

- **[AmatiVeneziano1981]** D. Amati, G. Veneziano, "Metric from matter", Physics Letters B 105 (1981) 358.
- **[AtkinsCalmet2013]** Michael Atkins, Xavier Calmet, "Bounds on the Nonminimal Coupling of the Higgs Boson to Gravity", Physical Review Letters 110 (2013) 051301, arXiv:1211.0281.
- **[BezrukovShaposhnikov2008]** Fedor L. Bezrukov, Mikhail Shaposhnikov, "The Standard Model Higgs boson as the inflaton", Physics Letters B 659 (2008) 703–706, arXiv:0710.3755.
- **[BirrellDavies1982]** N. D. Birrell, P. C. W. Davies, "Quantum Fields in Curved Space", Cambridge University Press (1982).
- **[BrodaSzanecki2009]** Boguslaw Broda, Michal Szanecki, "Induced gravity and gauge interactions revisited", Physics Letters B 674 (2009) 64–68, arXiv:0809.4203.
- **[ChamseddineConnes1997]** Ali H. Chamseddine, Alain Connes, "The spectral action principle", Communications in Mathematical Physics 186 (1997) 731–750, arXiv:hep-th/9606001.
- **[DonnellyWall2015]** William Donnelly, Aron C. Wall, "Entanglement entropy of electromagnetic edge modes", Physical Review Letters 114 (2015) 111603, arXiv:1412.1895.
- **[EcksteinIochum2018]** Michal Eckstein, Bruno Iochum, "Spectral Action in Noncommutative Geometry", Springer, SpringerBriefs in Mathematical Physics 27 (2018), arXiv:1902.05306.
- **[EstradaGraciaBondiaVarilly1998]** Ricardo Estrada, José M. Gracia-Bondía, Joseph C. Várilly, "On summability of distributions and spectral geometry", Communications in Mathematical Physics 191 (1998) 219–248, arXiv:funct-an/9702001.
- **[FramptonGlashowYanagida2002]** Paul H. Frampton, Sheldon L. Glashow, Tsutomu Yanagida, "Cosmological sign of neutrino CP violation", Physics Letters B 548 (2002) 119–121, arXiv:hep-ph/0208157.
- **[FrolovFursaevZelnikov1997]** V. P. Frolov, D. V. Fursaev, A. I. Zelnikov, "Statistical origin of black hole entropy in induced gravity", Nuclear Physics B 486 (1997) 339–352, arXiv:hep-th/9607104.
- **[Kabat1995]** Daniel Kabat, "Black Hole Entropy and Entropy of Entanglement", Nuclear Physics B 453 (1995) 281–302, arXiv:hep-th/9503016.
- **[LarsenWilczek1996]** Finn Larsen, Frank Wilczek, "Renormalization of Black Hole Entropy and of the Gravitational Coupling Constant", Nuclear Physics B 458 (1996) 249–266, arXiv:hep-th/9506066.
- **[PDG2024]** S. Navas et al. (Particle Data Group), "Review of Particle Physics", Physical Review D 110 (2024) 030001.
- **[Sakharov1967]** A. D. Sakharov, "Vacuum quantum fluctuations in curved space and the theory of gravitation", Doklady Akademii Nauk SSSR 177 (1967) 70–71.
- **[Solodukhin2011]** Sergey N. Solodukhin, "Entanglement entropy of black holes", Living Reviews in Relativity 14 (2011) 8, arXiv:1104.3712.
- **[Tanaka1996]** Masahiro Tanaka, "Three generations or more for an attractive gravity?", Physical Review D 53 (1996) 6941, arXiv:hep-ph/9504259.
- **[vanSuijlekom2024]** Walter D. van Suijlekom, "Noncommutative Geometry and Particle Physics", Springer, Mathematical Physics Studies, 2nd edition, open access (2024), doi:`10.1007/978-3-031-59120-4`.
- **[Vassilevich2003]** D. V. Vassilevich, "Heat kernel expansion: user's manual", Physics Reports 388 (2003) 279–360, arXiv:hep-th/0306138.
- **[Visser2002]** Matt Visser, "Sakharov's induced gravity: a modern perspective", Modern Physics Letters A 17 (2002) 977, arXiv:gr-qc/0204062.
