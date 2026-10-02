"""`make sensitivity`: the insertion weighting and neutrino rows (exact), the profiles'
moments and the magnitude range (from closed forms), written to results/sensitivity.json.
"""
from __future__ import annotations

from igc import results, sensitivity


def main() -> dict:
    return {
        "neutrino_rows": sensitivity.neutrino_rows(),
        "magnitude": sensitivity.magnitude(),
    }


if __name__ == "__main__":
    print(f"written to {results.write('sensitivity', main())}")
