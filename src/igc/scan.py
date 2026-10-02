"""The scan over contents with the Standard Model's gauge group: g generations, h Higgs
doublets and nu right-handed neutrinos. Every count goes through `count.totals` over a
content built by `table.Content`, the one definition of a content.

The Lean statements (lean/IGC/Generations.lean) range over all naturals. The searches
here are finite, and are reported with the range they covered; tests/test_scan.py checks
that, on that range, they find exactly what the Lean statements say.
"""
from __future__ import annotations

from fractions import Fraction

from igc import count, table

# The search range: generously past the solutions, which the Lean statements bound (a count
# of one needs 15g <= 49, so g <= 3, and 4h <= 49, so h <= 12).
SEARCH_GENERATIONS = 12
SEARCH_DOUBLETS = 20


class Scan:
    """The species table and the content, loaded once."""

    def __init__(self) -> None:
        self.species = table.load_species()
        self.content = table.load_content()

    def net(self, g: int, h: int, nu: int = 0) -> Fraction:
        K, I = count.totals(self.species, self.content.multiplicities(self.species, g, h, nu))
        return K + I

    def extension_net(self, vectors: int = 0, scalars: int = 0, weyl: int = 0) -> Fraction:
        """The count of the Standard Model extended by further gauge vectors (each with its
        ghosts), minimally coupled real scalars and Weyl fermions (`Content.extension`)."""
        mult = self.content.extension(self.species, vectors, scalars, weyl)
        K, I = count.totals(self.species, mult)
        return K + I

    def extensions(self) -> dict:
        """What one further gauge vector costs, and two extensions that carry one: alone,
        and with a complex scalar (two real scalars) to give it its mass. Lean's
        statements over every extension are lean/IGC/Extensions.lean's."""
        sm = self.extension_net()
        return {
            "one_boson": self.extension_net(vectors=1),
            "one_boson_and_complex_scalar": self.extension_net(vectors=1, scalars=2),
            "matter_per_boson": sm - self.extension_net(vectors=1),
        }

    def generation_counts(self, h: int | None = None) -> dict[int, Fraction]:
        """The count for zero up to the Standard Model's generations, with `h` doublets
        (the Standard Model's own number by default) and no right-handed neutrino."""
        h = self.content.standard_model_doublets if h is None else h
        return {g: self.net(g, h) for g in range(self.content.standard_model_generations + 1)}

    def counts_by_generations(self, g_max: int, h: int | None = None) -> dict[int, Fraction]:
        """The count for 0..g_max generations with `h` doublets: past the floor, to show it
        stays positive."""
        h = self.content.standard_model_doublets if h is None else h
        return {g: self.net(g, h) for g in range(g_max + 1)}

    def floor(self, h: int | None = None) -> dict:
        """The least number of generations with a positive count, and whether the count
        stays positive from there across the searched range."""
        h = self.content.standard_model_doublets if h is None else h
        counts = {g: self.net(g, h) for g in range(SEARCH_GENERATIONS)}
        least = min(g for g, n in counts.items() if n > 0)
        return {
            "doublets": h,
            "least_generations": least,
            "positive_from_there": all(counts[g] > 0 for g in range(least, SEARCH_GENERATIONS)),
            "searched_generations": SEARCH_GENERATIONS,
        }

    def solutions(self, target: int = 1, neutrino_per_generation: bool = False) -> list[list[int]]:
        """Every (generations, doublets) in the searched range whose count is `target`,
        with no right-handed neutrino, or with one in every generation."""
        return [
            [g, h]
            for g in range(SEARCH_GENERATIONS)
            for h in range(SEARCH_DOUBLETS)
            if self.net(g, h, g if neutrino_per_generation else 0) == target
        ]
