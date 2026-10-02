import IGC.Generated.Table
import IGC.Generated.Expected
import IGC.Weights
import IGC.Conditions
import IGC.Profile
import IGC.SpectralTrace
import IGC.ProperTime
import IGC.OneToSix
import IGC.InducedNewton
import IGC.Criterion
import IGC.StandardModel
import IGC.Generations
import IGC.Magnitude
import IGC.Horizon
import IGC.Coupling
import IGC.Extensions
import IGC.Agreement

/-!
# IGC

The Standard Model's induced Newton constant, counted exactly.

* `Weights` — each species' kinetic part and insertion (result 1).
* `Conditions` — K2 as a hypothesis, and where K1, K3 and K4 enter.
* `Profile` — cutoff profiles with their derivative as a measure, the sharp step
  included, and the integration by parts between their two moments.
* `SpectralTrace` — the heat trace and cutoff trace of an operator, the imported heat
  trace expansion, and the coefficient at order `L^s`.
* `ProperTime` — proper-time profiles, for which the cutoff trace's coefficient is proved
  from the heat trace alone.
* `OneToSix` — the curvature term as a shift of the spectrum, its first-order response,
  and why the two readings agree at one to six (result 2).
* `InducedNewton` — the regulated one-loop action, the induced Newton constant, and
  attraction.
* `Criterion` — positive exactly above the threshold ratio (result 3).
* `StandardModel` — −62, +63, net +1, and the headline (result 4).
* `Generations` — any number of generations, doublets and right-handed neutrinos: the
  floor, the least content, and the neutrino rows.
* `Magnitude` — the cutoff scale a Newton constant needs, and the profiles' moments.
* `Horizon` — 73 and −72, and agreement exactly under K2 (result 5).
* `Coupling` — the bound on the Higgs doublet's curvature coupling.
* `Extensions` — what a further gauge boson costs, the Standard Model extended by gauge
  bosons and matter, and the conformally coupled Higgs doublet.
* `Agreement` — every count Lean evaluates equals the one Python computes.

-/
