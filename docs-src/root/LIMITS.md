# Limits

GENERATED from `docs-src/root/LIMITS.md` by `make docs`. What this repository does **not** establish, stated plainly. [`CLAIMS.md`](CLAIMS.md) says what it does establish, and the status of each claim.

## What the conditions leave out

- **One loop (K2).** The count is the one-loop vacuum energy of each species. Higher loops are not considered.
- **The static coefficient only (K3).** What is computed is the coefficient of the curvature term in the regulated Euclidean action on a fixed background. Nothing here concerns an induced graviton's dynamics; with a regulator that is not Lorentz-invariant, a dynamical claim would need more than a static one.
- **The vacuum energy set aside (K4).** The cosmological term, the cutoff trace's leading order, is removed before the curvature coefficient is read off, and nothing is claimed about it.
- **The Higgs minimally coupled.** The headline takes the Higgs doublet minimally coupled to curvature. With a common coupling ξ the sign holds exactly when ξ < {{smCouplingBound}}; above that it reverses.
- **Whole generations and Higgs doublets.** The scan ranges over generations and doublets with the Standard Model's gauge group. Other representations are not scanned: two generations, four doublets and three singlet scalars, for one, would also count {{smNet}}.

## The limits of the formal development

{{limitationsList}}

## The magnitude is a range, not a prediction

The magnitude of Newton's constant depends on the cutoff's scale and on the profile's moment, which this repository treats as inputs. It reports the cutoff the Standard Model needs over three standard profiles, {{smCutoffLow}} to {{smCutoffHigh}} M_P, and claims nothing about which profile, or which scale, nature uses.

## What is imported

Each of these is taken from the literature, named as an input, and enters the Lean development as a hypothesis that theorems take, never as an axiom:

{{importedList}}

## What this repository cannot check about itself

- **That a Lean statement says what its claim says.** Lean checks that each statement is proved from its hypotheses. It does not check that the statement carries the claim it is cited for, in the claim's own words. [`CLAIMS.md`](CLAIMS.md) sets each claim beside its statements so that a reader can judge that; the repository does not judge it for itself.
- **That the inputs are right.** The imported results above enter as their sources state them, and the species table's entries as their citations give them. The computation checks the arithmetic built on them, not the entries themselves.
- **Independence.** The Python computation and the Lean development cross-check every count, and the build fails if they disagree. Both were written by the same author from the same table, so they guard against slips of arithmetic, not against a shared misreading of the physics.
