"""The scan over generations and doublets, against frozen values, and the finite search
against the universal statements of lean/IGC/Generations.lean.

The count is 15g + 4h + nu - 48. A count of one with no right-handed neutrino needs
15g + 4h = 49, so g <= 3 and h <= 12; with one in every generation it needs
16g + 4h = 49. The searched range covers both bounds, so on the question of a count of
one the finite search is exhaustive, and must find exactly what the Lean statements
say: (3, 1), and nothing with a neutrino per generation.
"""
import json
import pathlib
from fractions import Fraction

import pytest

from igc import scan

ROOT = pathlib.Path(__file__).resolve().parents[1]
FIXTURE = json.loads((ROOT / "tests" / "fixtures" / "scan_equivalence.json").read_text())


@pytest.fixture(scope="module")
def s():
    return scan.Scan()


@pytest.mark.parametrize("g", sorted(FIXTURE["generation_counts_one_doublet"], key=int))
def test_generation_count_matches_fixture(g, s):
    assert s.net(int(g), 1) == Fraction(FIXTURE["generation_counts_one_doublet"][g])


def test_count_is_its_closed_form(s):
    for g in range(scan.SEARCH_GENERATIONS):
        for h in range(scan.SEARCH_DOUBLETS):
            for nu in (0, 1, g):
                assert s.net(g, h, nu) == 15 * g + 4 * h + nu - 48


def test_floor(s):
    f = s.floor()
    assert f["least_generations"] == 3 and f["positive_from_there"]


def test_search_covers_every_count_of_one():
    assert scan.SEARCH_GENERATIONS > 49 // 15 and scan.SEARCH_DOUBLETS > 49 // 4


def test_count_one_solutions(s):
    assert s.solutions(1) == FIXTURE["count_one_solutions"] == [[3, 1]]
    assert (s.solutions(1, neutrino_per_generation=True)
            == FIXTURE["count_one_solutions_with_a_neutrino_per_generation"] == [])
