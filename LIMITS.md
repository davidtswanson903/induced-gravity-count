# Limits

GENERATED from `docs-src/root/LIMITS.md` by `make docs`. What this repository does **not** establish, stated plainly. [`CLAIMS.md`](CLAIMS.md) says what it does establish, and the status of each claim.

## What the conditions leave out

- **One loop (K2).** The count is the one-loop vacuum energy of each species. Higher loops are not considered.
- **The static coefficient only (K3).** What is computed is the coefficient of the curvature term in the regulated Euclidean action on a fixed background. Nothing here concerns an induced graviton's dynamics; with a regulator that is not Lorentz-invariant, a dynamical claim would need more than a static one.
- **The vacuum energy set aside (K4).** The cosmological term, the cutoff trace's leading order, is removed before the curvature coefficient is read off, and nothing is claimed about it.
- **The Higgs minimally coupled.** The headline takes the Higgs doublet minimally coupled to curvature. With a common coupling ξ the sign holds exactly when ξ < 1/24; above that it reverses.
- **Whole generations and Higgs doublets.** The scan ranges over generations and doublets with the Standard Model's gauge group. Other representations are not scanned: two generations, four doublets and three singlet scalars, for one, would also count +1.

## The limits of the formal development

1. **profile-scope.** The induced coefficient's expansion in the profile's moment is proved here for proper-time profiles: Laplace transforms of finite measures carried by a bounded proper-time interval. For other profiles it is imported where the literature states it, for Laplace-transform and for Schwartz profiles. The Schwinger proper-time cutoff, whose proper-time measure is infinite, would need a spectral gap and is not covered.
2. **sharp-cutoff-in-mean.** For the sharp cutoff the moments obey the integration-by-parts identity exactly, so its weighting is six. But its cutoff trace has no expansion beyond the leading term except in the Cesàro sense, so for the sharp step the induced coefficient is defined only as a mean.
3. **constant-insertion.** The second reading of the one-to-six, as the cutoff trace's first-order response to the curvature insertion, is formalized for an insertion that shifts the spectrum by a constant. A position-dependent insertion would need the operator's perturbation theory. The induced coefficient does not rest on this reading: it uses the heat kernel's coefficient for the full operator.
4. **induced-premise.** The constraints on content hold only if Newton's constant is entirely induced by the species below the cutoff, with no bare term: Sakharov's premise, which this repository does not argue for. With a bare term, the count gives only the sign of matter's contribution to 1/G. The constraints concern the complete content below a cutoff of a few Planck masses, so the matter that pays for a gauge boson may lie anywhere below it: they constrain complete models, and no single discovery tests them.
5. **other-operator.** A cutoff taken in an operator other than the fluctuation operator is not modelled. K1's contrast with such a cutoff is the condition's motivation, not a result of this paper.

## The magnitude is a range, not a prediction

The magnitude of Newton's constant depends on the cutoff's scale and on the profile's moment, which this repository treats as inputs. It reports the cutoff the Standard Model needs over three standard profiles, 6.140 to 6.522 M_P, and claims nothing about which profile, or which scale, nature uses.

## What is imported

Each of these is taken from the literature, named as an input, and enters the Lean development as a hypothesis that theorems take, never as an axiom:

- The heat trace of each species' fluctuation operator, a Laplace-type operator on a closed manifold: its small-τ expansion through order τ with an O(τ²) remainder, consumed as the Lean structure IGC.HeatTrace; and its first two coefficients, a₀ and a₁ = (4π)^(−d/2) ∫ tr(R/6 − E), that is (4π)^(−d/2) (N/6 − c) ∫√g R for a species of N components whose curvature term has trace c R, consumed as the Lean structure IGC.Background (Vassilevich, eqs. 2.21 and 4.26–4.27; for a scalar with curvature coupling ξ, a₁ ∝ 1/6 − ξ, Birrell and Davies, ch. 6). Cited: [Vassilevich2003], [BirrellDavies1982].
- For profiles outside the proper-time class, where it is proved instead: the cutoff trace Tr f(D/L) carries at order L^s the heat trace's a₁ times the profile's moment ∫ f(u) u^(s − 1) du divided by Γ(s), consumed as the Lean predicate IGC.SpectralActionA1. Stated for Laplace-transform profiles by van Suijlekom (Prop. 9.7) and Eckstein and Iochum (Cor. 3.33), for Schwartz profiles by Estrada, Gracia-Bondía and Várilly, and in four dimensions by Chamseddine and Connes (eqs. 2.14–2.15). For the sharp cutoff it holds only in the Cesàro sense (Estrada, Gracia-Bondía and Várilly, sec. 6), which the predicate does not express. Cited: [vanSuijlekom2024], [EcksteinIochum2018], [EstradaGraciaBondiaVarilly1998], [ChamseddineConnes1997].
- The sign convention: the regulated Euclidean one-loop action is ½ Σ σ log det D over species, and its curvature term is −(1/16πG) ∫√g R, so that a minimally coupled scalar induces a positive 1/G, fixed in the Lean definitions IGC.oneLoopAction and IGC.InducesNewton (Frolov, Fursaev and Zelnikov, eqs. 2.10 and 2.19). Cited: [FrolovFursaevZelnikov1997].
- Each species' statistics sign, components and curvature trace, and the weights a minimal scalar, a Weyl fermion and a gauge field with its ghosts induce, in data/species.yaml and the Lean rows IGC.Generated.minimalScalar, weylFermion, vector and ghost. Cited: [BirrellDavies1982], [BrodaSzanecki2009], [Kabat1995].
- The Standard Model's content by its parts: the gauge group's twelve vectors, each with two ghosts; fifteen Weyl fermions per generation, without a right-handed neutrino; four real scalars per Higgs doublet; three generations and one doublet. In data/species.yaml's content block and the generated Lean definition IGC.Generated.smContent. Cited: [PDG2024], [BrodaSzanecki2009].
- Each species' coefficient in the horizon's entanglement entropy, in units of one minimally coupled real scalar (a minimal scalar 1, a Weyl fermion 1, a vector 2 for its two physical polarizations, a ghost 0), in data/species.yaml's entanglement column and the Lean field IGC.Generated.SpeciesRow.entanglement. Cited: [Kabat1995], [LarsenWilczek1996].
- The contact term is what reconciles the induced coupling with horizon entropy: −6 per gauge field, in scalar units, in data/species.yaml's contact column and the Lean field IGC.Generated.SpeciesRow.contact. Cited: [Kabat1995].
- the proportionality between horizon entropy and the induced coupling. Cited: [LarsenWilczek1996].
- Higgs inflation's curvature coupling, ξ ≈ 49000 √λ in Bezrukov and Shaposhnikov's convention (their eq. 13), in which the conformal coupling is minus one sixth (their footnote 1). In this repository's convention, where it is plus one sixth, the same coupling is negative, so the count 1 − 24ξ rises with it. Cited: [BezrukovShaposhnikov2008].

## What this repository cannot check about itself

- **That a Lean statement says what its claim says.** Lean checks that each statement is proved from its hypotheses. It does not check that the statement carries the claim it is cited for, in the claim's own words. [`CLAIMS.md`](CLAIMS.md) sets each claim beside its statements so that a reader can judge that; the repository does not judge it for itself.
- **That the inputs are right.** The imported results above enter as their sources state them, and the species table's entries as their citations give them. The computation checks the arithmetic built on them, not the entries themselves.
- **Independence.** The Python computation and the Lean development cross-check every count, and the build fails if they disagree. Both were written by the same author from the same table, so they guard against slips of arithmetic, not against a shared misreading of the physics.
