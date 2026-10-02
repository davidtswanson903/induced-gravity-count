"""How the result moves with what the paper leaves open: the insertion's weighting, the
neutrino content, and the cutoff profile -- which the sign does not depend on, and the
magnitude does.

- **Insertion weighting.** The count is positive exactly when the insertion's weighting
  exceeds 6|K|/I (`count.criterion`); K1 gives six. Exact.
- **Neutrino rows.** The Standard Model with 0, 2 and 3 right-handed neutrinos: the
  threshold, the margin, the Higgs coupling bound, and the count with the doublet
  conformally coupled. Exact.
- **Profiles.** Three standard profiles, with their normalized moments M in closed form
  (lean/IGC/Magnitude.lean): the sharp step, 1/Gamma(s+1); the heat kernel's own e^(-u),
  1; the Gaussian e^(-u^2), Gamma(s/2)/(2 Gamma(s)).
- **Magnitude.** In four dimensions a content of net count `net` under a profile of
  moment M induces Newton's constant at the cutoff Lambda = M_P sqrt(12 pi / (M net)),
  with M_P = G^(-1/2) (lean/IGC/Magnitude.lean, `cutoff_for_newton`). Floats, evaluated
  from closed forms; no quadrature enters.
"""
from __future__ import annotations

import math
from fractions import Fraction

from igc import count, table

# Four dimensions: s = d/2 - 1.
S_FOUR = 1.0

# The conformal coupling in four dimensions, (d - 2) / (4 (d - 1)) = 1/6, in the
# convention where minimal coupling is 0 (Birrell and Davies, ch. 3).
CONFORMAL_COUPLING = Fraction(1, 6)

PROFILES = ("sharp_step", "heat_kernel", "gaussian")


def normalized_moment(profile: str, s: float = S_FOUR) -> float:
    """The profile's moment against the heat kernel's own, in closed form."""
    if profile == "sharp_step":
        return 1.0 / math.gamma(s + 1.0)
    if profile == "heat_kernel":
        return 1.0
    if profile == "gaussian":
        return math.gamma(s / 2.0) / (2.0 * math.gamma(s))
    raise KeyError(profile)


def cutoff_over_planck(moment: float, net: Fraction) -> float:
    """Lambda / M_P = sqrt(12 pi / (M net)): the cutoff at which the count induces
    Newton's constant, in four dimensions."""
    if net <= 0:
        raise ValueError("a non-positive count induces no attractive Newton constant")
    return math.sqrt(12.0 * math.pi / (moment * float(net)))


def neutrino_rows() -> dict[str, dict]:
    """Per branch: its right-handed neutrinos, counts, threshold weighting, margin and
    the Higgs coupling bound, exact."""
    species = table.load_species()
    branches = table.load_branches()
    neutrinos = table.branch_neutrinos()
    rows = {}
    for name, mult in branches.items():
        K, I = count.totals(species, mult)
        c = count.criterion(K, I)
        rows[name] = {
            "right_handed_neutrinos": neutrinos[name],
            "net": c["net"],
            "threshold": c["threshold"],
            "margin": c["margin"],
            "coupling_bound": count.coupling_bound(species, mult),
            "conformal_count": count.net_with_coupling(species, mult, CONFORMAL_COUPLING),
        }
    return rows


def magnitude() -> dict:
    """Lambda / M_P for every profile and branch, and the Standard Model's range over the
    profiles."""
    rows = neutrino_rows()
    moments = {p: normalized_moment(p) for p in PROFILES}
    table_ = {
        branch: {p: cutoff_over_planck(moments[p], row["net"]) for p in PROFILES}
        for branch, row in rows.items()
    }
    sm_branch = next(b for b, row in rows.items() if row["right_handed_neutrinos"] == 0)
    sm = table_[sm_branch]
    return {
        "moments": moments,
        "cutoff_over_planck": table_,
        "standard_model_range": [min(sm.values()), max(sm.values())],
    }
