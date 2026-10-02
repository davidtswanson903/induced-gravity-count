"""The kinetic parts, curvature insertions, net count and sign criterion -- the one
formula every caller reaches through here, exact throughout.

Nothing here derives *why* the insertion's weighting is 6 (that is condition K1 and
the profile-independence identity, lean/IGC/OneToSix.lean) -- this module computes the
threshold a content's own kinetic/insertion split has to clear, and reports how far 6
is above it.
"""
from __future__ import annotations

from fractions import Fraction

from igc.table import Species


def kinetic(species: Species) -> Fraction:
    return Fraction(species.statistics_sign * species.real_components)


def insertion(species: Species) -> Fraction:
    return -6 * species.curvature_trace * species.statistics_sign


def weight(species: Species) -> Fraction:
    return kinetic(species) + insertion(species)


def totals(species_table: dict[str, Species], mult: dict[str, int]) -> tuple[Fraction, Fraction]:
    """(K, I): the kinetic and insertion totals over a branch's multiplicities."""
    K = sum((mult[n] * kinetic(species_table[n]) for n in mult), Fraction(0))
    I = sum((mult[n] * insertion(species_table[n]) for n in mult), Fraction(0))
    return K, I


def coupling_bound(
    species_table: dict[str, Species], mult: dict[str, int], scalar: str = "minimal_scalar"
) -> Fraction:
    """The largest curvature coupling xi the scalar can carry with the count still
    positive. Giving the scalar's row curvature trace xi turns its weight into
    (1 - 6 xi), so the net is rest + s (1 - 6 xi), positive exactly when
    xi < (rest + s) / (6 s), with s the scalar's multiplicity and rest everything else.
    """
    row = species_table[scalar]
    if (row.statistics_sign, row.real_components, row.curvature_trace) != (1, 1, 0):
        raise ValueError(f"{scalar!r} is not a single minimally coupled real scalar")
    s = mult[scalar]
    rest = sum(
        (m * weight(species_table[n]) for n, m in mult.items() if n != scalar), Fraction(0)
    )
    return (rest + s) / (6 * s)


def net_with_coupling(
    species_table: dict[str, Species], mult: dict[str, int], xi: Fraction,
    scalar: str = "minimal_scalar",
) -> Fraction:
    """The net count with the scalar's curvature coupling set to xi: rest + s (1 - 6 xi),
    the count whose sign `coupling_bound` locates."""
    row = species_table[scalar]
    if (row.statistics_sign, row.real_components, row.curvature_trace) != (1, 1, 0):
        raise ValueError(f"{scalar!r} is not a single minimally coupled real scalar")
    rest = sum(
        (m * weight(species_table[n]) for n, m in mult.items() if n != scalar), Fraction(0)
    )
    return rest + mult[scalar] * (1 - 6 * Fraction(xi))


def criterion(K: Fraction, I: Fraction) -> dict:
    """The net count, whether it is positive, the threshold ratio a weighting has to
    clear (`6 |K| / I`), and the margin by which the heat kernel's own 6 clears it."""
    net = K + I
    threshold = 6 * abs(K) / I
    margin = (6 - threshold) / 6
    return {
        "K": K,
        "I": I,
        "net": net,
        "positive": net > 0,
        "threshold": threshold,
        "margin": margin,
    }
