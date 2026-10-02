"""The horizon-entropy side of the count: entanglement (each species' coefficient in
the horizon's entanglement entropy, `entanglement`, in units of one real scalar) and
the contact term (each species' own `contact`), both independently cited in
data/species.yaml.

Neither is computed from the weight. That is what makes `Ent + Con == K + I` a
check rather than a definition: it holds over a branch exactly when every gauge
field carries its two ghosts (condition K2), since the gauge field's contact term
is cited for the field with its ghosts.
"""
from __future__ import annotations

from fractions import Fraction

from igc.table import Species


def totals(species_table: dict[str, Species], mult: dict[str, int]) -> tuple[Fraction, Fraction]:
    """(Ent, Con): the entanglement and contact totals over a branch's multiplicities."""
    Ent = sum((mult[n] * species_table[n].entanglement for n in mult), Fraction(0))
    Con = sum((mult[n] * species_table[n].contact for n in mult), Fraction(0))
    return Ent, Con
