"""Writing results/*.json: the one place a computed value is serialized.

Fractions are written as "num/den" strings (a bare integer string when the denominator
is 1), the same exact form tests/fixtures/*.json use, so the two compare by eye. Floats,
which appear only where a value is not exact, are written as JSON numbers.
"""
from __future__ import annotations

import json
import pathlib
from fractions import Fraction

ROOT = pathlib.Path(__file__).resolve().parents[2]
RESULTS_DIR = ROOT / "results"


def fraction_str(x: Fraction) -> str:
    return str(x.numerator) if x.denominator == 1 else f"{x.numerator}/{x.denominator}"


def serializable(obj):
    """`obj` with every Fraction as its exact string and every key as a string."""
    if isinstance(obj, Fraction):
        return fraction_str(obj)
    if isinstance(obj, dict):
        return {str(k): serializable(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [serializable(v) for v in obj]
    return obj


def write(name: str, obj: dict) -> pathlib.Path:
    """Write results/<name>.json."""
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    path = RESULTS_DIR / f"{name}.json"
    path.write_text(json.dumps(serializable(obj), indent=2), encoding="utf-8")
    return path
