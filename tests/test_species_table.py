"""The species table's own closed-form checks. Three columns of data/species.yaml are cited
independently of the (sign, components, curvature_trace) formula -- the
conventional cross-checks, entanglement and contact -- and these tests are what make
comparing them against the formula real rather than aspirational.
"""
from fractions import Fraction

from igc import count, table


def _weight_of(species, mult: dict[str, int]) -> Fraction:
    return sum((m * count.weight(species[n]) for n, m in mult.items()), Fraction(0))


def test_cross_checks_match_the_computed_weight():
    species = table.load_species()
    checks = table.load_cross_checks()
    assert checks, "no conventional_cross_checks found in data/species.yaml"
    for check in checks:
        computed = _weight_of(species, check.species)
        assert computed == check.weight, (
            f"{check.name!r}: formula gives {computed}, "
            f"but {', '.join(check.citations)} state {check.weight}"
        )


def test_horizon_columns_reproduce_the_weight():
    """Kabat: black hole entropy is entanglement plus a contact term, and it equals
    the induced weight. So entanglement + contact must reproduce the formula's weight
    -- for each species with no contact term, and for a gauge field taken with its two
    ghosts, since that is the unit the contact term is cited for. Not for the vector
    or ghost row alone, which this test deliberately does not check."""
    species = table.load_species()
    units = [
        {"minimal_scalar": 1},
        {"weyl_fermion": 1},
        {"vector": 1, "ghost": 2},
    ]
    for unit in units:
        horizon = sum(
            (m * (species[n].entanglement + species[n].contact) for n, m in unit.items()),
            Fraction(0),
        )
        assert horizon == _weight_of(species, unit), (
            f"{unit}: entanglement + contact = {horizon}, "
            f"weight = {_weight_of(species, unit)}"
        )


def test_only_the_gauge_sector_has_a_contact_term():
    species = table.load_species()
    for name, s in species.items():
        if name != "vector":
            assert s.contact == 0, f"{name} carries a contact term ({s.contact})"
