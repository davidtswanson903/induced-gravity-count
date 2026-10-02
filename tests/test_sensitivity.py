"""The sensitivity: exact rows against count.py and the frozen count fixtures, and the
magnitude against its closed form."""
import json
import math
import pathlib
from fractions import Fraction

from igc import count, sensitivity, table

ROOT = pathlib.Path(__file__).resolve().parents[1]
COUNTS = json.loads((ROOT / "tests" / "fixtures" / "count_equivalence.json").read_text())
SCAN = json.loads((ROOT / "tests" / "fixtures" / "scan_equivalence.json").read_text())


def test_neutrino_rows_match_the_count_fixtures():
    for name, row in sensitivity.neutrino_rows().items():
        expected = COUNTS["branches"][name]
        assert row["net"] == Fraction(expected["net"])
        assert row["threshold"] == Fraction(expected["threshold"])
        assert row["margin"] == Fraction(expected["margin"])
        assert row["coupling_bound"] == Fraction(expected["coupling_bound"])


def test_moments_in_four_dimensions():
    assert sensitivity.normalized_moment("sharp_step") == 1.0
    assert sensitivity.normalized_moment("heat_kernel") == 1.0
    assert math.isclose(sensitivity.normalized_moment("gaussian"), math.sqrt(math.pi) / 2,
                        rel_tol=1e-15)


def test_cutoff_closed_form_and_fixture():
    lam = sensitivity.cutoff_over_planck(1.0, Fraction(1))
    assert math.isclose(lam, math.sqrt(12 * math.pi), rel_tol=1e-15)
    frozen = SCAN["cutoff_over_planck_unit_moment_unit_count"]
    assert abs(lam - frozen["value"]) <= frozen["printed_to"] / 2


def test_standard_model_range():
    lo, hi = sensitivity.magnitude()["standard_model_range"]
    assert math.isclose(lo, math.sqrt(12 * math.pi), rel_tol=1e-15)
    assert math.isclose(hi, math.sqrt(12 * math.pi / (math.sqrt(math.pi) / 2)), rel_tol=1e-15)


def test_more_neutrinos_lower_the_cutoff():
    cut = sensitivity.magnitude()["cutoff_over_planck"]
    nets = {name: row["net"] for name, row in sensitivity.neutrino_rows().items()}
    for p in sensitivity.PROFILES:
        by_net = sorted(cut, key=lambda b: nets[b])
        values = [cut[b][p] for b in by_net]
        assert values == sorted(values, reverse=True)
