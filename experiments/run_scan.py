"""`make scan`: the count over generations and doublets -- the floor and the least
content -- and the cost of a further gauge vector, written to results/scan.json. The searches are finite and say so; the
universal statements are lean/IGC/Generations.lean's.
"""
from __future__ import annotations

from igc import results, scan


def main() -> dict:
    s = scan.Scan()
    return {
        "generation_counts": s.generation_counts(),
        "counts_to_six_generations": s.counts_by_generations(6),
        "floor": s.floor(),
        "count_one": {
            "searched": {"generations": scan.SEARCH_GENERATIONS, "doublets": scan.SEARCH_DOUBLETS},
            "solutions": s.solutions(1),
            "solutions_with_a_neutrino_per_generation": s.solutions(1, neutrino_per_generation=True),
        },
        "extensions": s.extensions(),
    }


if __name__ == "__main__":
    print(f"written to {results.write('scan', main())}")
