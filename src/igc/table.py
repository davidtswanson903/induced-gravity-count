"""Loads data/species.yaml and data/references.yaml. The only reader of either file
in Python -- every other module reaches the species table through this one.

Precedence rules, from data/species.yaml's own header, restated where a reader checks
them against the data:
    - Fermions are entered as Weyl; Dirac/Majorana counts are derived, never entered.
    - `real_components` is per real field, covariant (off-shell) count -- not what the
      horizon count uses, which is `entanglement`: each species' coefficient in the
      horizon's entanglement entropy, in units of one minimally coupled real scalar
      (a Weyl fermion counts 1, though it has two physical degrees of freedom).
    - `curvature_trace` is exact (a rational), converted to `fractions.Fraction` here
      so every later computation on it stays exact.
    - `conventional_cross_checks`, `entanglement` and `contact` are independently
      cited, never derived from the other columns -- a consistency check needs an
      independent target, not a restatement of its own formula.
    - Only the gauge sector has a nonzero `contact`, carried on the vector row for a
      gauge field with its two ghosts.
"""
from __future__ import annotations

import pathlib
from dataclasses import dataclass
from fractions import Fraction

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[2]
SPECIES_PATH = ROOT / "data" / "species.yaml"
REFERENCES_PATH = ROOT / "data" / "references.yaml"


@dataclass(frozen=True, slots=True)
class Species:
    name: str
    statistics_sign: int
    real_components: int
    curvature_trace: Fraction
    entanglement: int
    contact: int
    citation: str
    horizon_citation: str


@dataclass(frozen=True, slots=True)
class CrossCheck:
    name: str
    species: dict[str, int]
    weight: int
    citations: tuple[str, ...]


def _load(path: pathlib.Path) -> dict:
    with open(path, encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def load_references(path: pathlib.Path = REFERENCES_PATH) -> dict:
    """Every citation key -> its bibliographic record, read as-is from YAML."""
    return _load(path)


def load_species(path: pathlib.Path = SPECIES_PATH) -> dict[str, Species]:
    """Every species, keyed by name, with `curvature_trace` as an exact Fraction."""
    raw = _load(path)
    return {
        name: Species(
            name=name,
            statistics_sign=row["statistics_sign"],
            real_components=row["real_components"],
            curvature_trace=Fraction(row["curvature_trace"]),
            entanglement=row["entanglement"],
            contact=row["contact"],
            citation=row["citation"],
            horizon_citation=row["horizon_citation"],
        )
        for name, row in raw["species"].items()
    }


def load_cross_checks(path: pathlib.Path = SPECIES_PATH) -> list[CrossCheck]:
    """The independently-cited weight totals, each carrying the citations they share."""
    block = _load(path)["conventional_cross_checks"]
    citations = tuple(block["citations"])
    return [
        CrossCheck(
            name=entry["name"],
            species=dict(entry["species"]),
            weight=entry["weight"],
            citations=citations,
        )
        for entry in block["checks"]
    ]


@dataclass(frozen=True, slots=True)
class Content:
    """The content block of species.yaml: a content's parts, per unit of each
    parameter. `multiplicities` is the one place a content is turned into counts."""
    citations: tuple[str, ...]
    gauge_group: dict[str, int]
    per_gauge_vector: dict[str, int]
    per_generation: dict[str, int]
    per_doublet: dict[str, int]
    per_right_handed_neutrino: dict[str, int]
    standard_model_generations: int
    standard_model_doublets: int

    @property
    def gauge_vectors(self) -> int:
        return sum(self.gauge_group.values())

    def multiplicity(self, name: str, g: int, h: int, nu: int) -> int:
        """How many of species `name` a content of g generations, h doublets and nu
        right-handed neutrinos carries."""
        return (
            self.gauge_group.get(name, 0)
            + self.per_gauge_vector.get(name, 0) * self.gauge_vectors
            + self.per_generation.get(name, 0) * g
            + self.per_doublet.get(name, 0) * h
            + self.per_right_handed_neutrino.get(name, 0) * nu
        )

    def multiplicities(self, species_names, g: int, h: int, nu: int = 0) -> dict[str, int]:
        """Every species' multiplicity, in the table's species order. Species absent from
        a content are carried with multiplicity 0, so every content lists the same rows."""
        return {name: self.multiplicity(name, g, h, nu) for name in species_names}

    def extension(self, species_names, vectors: int = 0, scalars: int = 0,
                  weyl: int = 0) -> dict[str, int]:
        """The Standard Model extended by `vectors` further gauge vectors, each with its
        ghosts (`per_gauge_vector`), `scalars` further minimally coupled real scalars and
        `weyl` further Weyl fermions."""
        m = self.multiplicities(species_names, self.standard_model_generations,
                                self.standard_model_doublets)
        m["vector"] += vectors
        for name, per in self.per_gauge_vector.items():
            m[name] += per * vectors
        m["minimal_scalar"] += scalars
        m["weyl_fermion"] += weyl
        return m


def load_content(path: pathlib.Path = SPECIES_PATH) -> Content:
    raw = _load(path)["content"]
    return Content(
        citations=tuple(raw["citations"]),
        gauge_group=dict(raw["gauge_group"]),
        per_gauge_vector=dict(raw["per_gauge_vector"]),
        per_generation=dict(raw["per_generation"]),
        per_doublet=dict(raw["per_doublet"]),
        per_right_handed_neutrino=dict(raw["per_right_handed_neutrino"]),
        standard_model_generations=raw["standard_model"]["generations"],
        standard_model_doublets=raw["standard_model"]["doublets"],
    )


def content(g: int, h: int, nu: int = 0, path: pathlib.Path = SPECIES_PATH) -> dict[str, int]:
    """The multiplicity map of a content with g generations, h Higgs doublets and nu
    right-handed neutrinos, over every species in the table."""
    return load_content(path).multiplicities(load_species(path), g, h, nu)


def load_branches(path: pathlib.Path = SPECIES_PATH) -> dict[str, dict[str, int]]:
    """Every Standard Model branch, keyed by its right-handed-neutrino content, to a
    multiplicity map over species names -- derived from the content block, never
    entered."""
    c = load_content(path)
    names = list(load_species(path))
    return {
        name: c.multiplicities(names, c.standard_model_generations, c.standard_model_doublets,
                               spec["right_handed_neutrinos"])
        for name, spec in _load(path)["branches"].items()
    }


def branch_neutrinos(path: pathlib.Path = SPECIES_PATH) -> dict[str, int]:
    """Each branch's number of right-handed neutrinos."""
    return {name: spec["right_handed_neutrinos"] for name, spec in _load(path)["branches"].items()}
