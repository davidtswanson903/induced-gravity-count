"""Equivalence with frozen values: every number computed here is checked, exactly,
against tests/fixtures/count_equivalence.json. Every quantity is an exact ratio of
integers, so the check is equality on Fractions, never a tolerance.
"""
import json
import pathlib
from fractions import Fraction

import pytest

from igc import count, horizon, table

ROOT = pathlib.Path(__file__).resolve().parents[1]
FIXTURE = json.loads((ROOT / "tests" / "fixtures" / "count_equivalence.json").read_text())


@pytest.fixture(scope="module")
def species():
    return table.load_species()


@pytest.fixture(scope="module")
def branches():
    return table.load_branches()


@pytest.mark.parametrize("branch_name", sorted(FIXTURE["branches"]))
def test_count_matches_fixture(branch_name, species, branches):
    expected = FIXTURE["branches"][branch_name]
    K, I = count.totals(species, branches[branch_name])
    c = count.criterion(K, I)
    assert K == Fraction(expected["K"])
    assert I == Fraction(expected["I"])
    assert c["net"] == Fraction(expected["net"])
    assert c["threshold"] == Fraction(expected["threshold"])
    assert c["margin"] == Fraction(expected["margin"])
    assert count.coupling_bound(species, branches[branch_name]) == Fraction(
        expected["coupling_bound"]
    )


@pytest.mark.parametrize("branch_name", sorted(FIXTURE["branches"]))
def test_horizon_matches_fixture(branch_name, species, branches):
    expected = FIXTURE["branches"][branch_name]
    Ent, Con = horizon.totals(species, branches[branch_name])
    assert Ent == Fraction(expected["entanglement"])
    assert Con == Fraction(expected["contact"])


@pytest.mark.parametrize("branch_name", sorted(FIXTURE["branches"]))
def test_horizon_net_agrees_with_count_net(branch_name, species, branches):
    """Not a fixture check: the weight formula (Birrell-Davies' per-field
    coefficients) and the horizon columns (Kabat's entanglement and contact term,
    cited separately) reach the same net, for every branch, not just the Standard
    Model's."""
    mult = branches[branch_name]
    K, I = count.totals(species, mult)
    Ent, Con = horizon.totals(species, mult)
    assert Ent + Con == K + I
