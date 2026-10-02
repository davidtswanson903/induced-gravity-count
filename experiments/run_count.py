"""`make count`: the kinetic/insertion totals, the sign criterion, and the horizon
count, for every branch in data/species.yaml, written to results/count.json.
"""
from __future__ import annotations

from igc import count, horizon, results, table


def main() -> dict:
    species = table.load_species()
    out = {"branches": {}}
    for name, mult in table.load_branches().items():
        K, I = count.totals(species, mult)
        c = count.criterion(K, I)
        Ent, Con = horizon.totals(species, mult)
        out["branches"][name] = {
            "K": K,
            "I": I,
            "net": c["net"],
            "positive": c["positive"],
            "threshold": c["threshold"],
            "margin": c["margin"],
            "entanglement": Ent,
            "contact": Con,
            "by_species": {
                s: {
                    "multiplicity": m,
                    "kinetic": m * count.kinetic(species[s]),
                    "insertion": m * count.insertion(species[s]),
                    "weight": m * count.weight(species[s]),
                    "entanglement": m * species[s].entanglement,
                    "contact": m * species[s].contact,
                }
                for s, m in mult.items()
            },
        }
    return out


if __name__ == "__main__":
    print(f"written to {results.write('count', main())}")
