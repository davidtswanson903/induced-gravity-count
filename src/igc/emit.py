"""Every number the generated documents quote comes from here, never typed in a template.

`macros()` reads results/*.json (and the content block of data/species.yaml, for the
counts of fields a document names) into named values, once. Every generated document is
filled from the same dict, so a regenerated result changes all of them together or none:
tests/test_numbers_rule.py checks that no generated document carries a number this
module did not supply.

`blocks()` renders the lists a document carries whole -- the conditions, the
limitations, the imported inputs, the references -- from the registry
(src/igc/claims.py) and data/references.yaml, never retyped.

House style for a computed integer: always signed (`+1`, not `1`; `−62`, with the
typographic minus the claims themselves use), so a computed count is distinguishable
from a hand-typed one -- tests/test_numbers_rule.py's `_SIGNED_INT_RE` relies on it.
A macro's name is also the LaTeX command it becomes in the paper's feed.
"""
from __future__ import annotations

import json
import math
import pathlib
from fractions import Fraction

from igc import claims, table

ROOT = pathlib.Path(__file__).resolve().parents[2]
RESULTS_DIR = ROOT / "results"
RESULTS = ("count", "scan", "sensitivity")

GENERATED_DOCS = [
    ROOT / "README.md",
    ROOT / "LIMITS.md",
    ROOT / "PROVENANCE.md",
    *sorted((ROOT / "docs").glob("*.md")),
]

_WORD = {0: "Zero", 1: "One", 2: "Two", 3: "Three", 4: "Four", 5: "Five", 6: "Six"}
MINUS = "−"


# ---------------------------------------------------------------- formatting
def signed_int(n: int) -> str:
    """An integer, always with an explicit sign -- the one place this house style turns
    a computed integer into text. Zero, which has no sign, is written `0`."""
    if n == 0:
        return "0"
    return f"+{n}" if n > 0 else f"{MINUS}{-n}"


def signed(x: Fraction | str) -> str:
    x = Fraction(x)
    if x.denominator != 1:
        raise ValueError(f"{x} is not an integer")
    return signed_int(x.numerator)


def fraction(x: Fraction | str) -> str:
    x = Fraction(x)
    s = str(x.numerator) if x.denominator == 1 else f"{x.numerator}/{x.denominator}"
    return s.replace("-", MINUS)


def sig(x: float, n: int = 4) -> str:
    """`n` significant figures, plain notation."""
    x = float(x)
    if x == 0:
        return "0"
    exp = math.floor(math.log10(abs(x)))
    return f"{x:.{max(n - 1 - exp, 0)}f}"


def pct(x: Fraction | str | float, n: int = 3) -> str:
    """A fraction as a percentage to `n` significant figures, e.g. `1.59%`."""
    return sig(100 * float(Fraction(x)), n) + "%"


# ---------------------------------------------------------------------- macros
def load_results() -> dict:
    return {name: json.loads((RESULTS_DIR / f"{name}.json").read_text(encoding="utf-8"))
            for name in RESULTS}


def macros(results: dict | None = None) -> dict[str, str]:
    """Every named number the documents quote, as the text they quote it in."""
    r = results or load_results()
    m: dict[str, str] = {}

    rows = r["sensitivity"]["neutrino_rows"]
    prefix = {name: ("sm" if row["right_handed_neutrinos"] == 0
                     else f"nu{_WORD[row['right_handed_neutrinos']]}")
              for name, row in rows.items()}

    for name, b in r["count"]["branches"].items():
        p = prefix[name]
        m[f"{p}Kinetic"] = signed(b["K"])
        m[f"{p}Insertion"] = signed(b["I"])
        m[f"{p}Net"] = signed(b["net"])
        m[f"{p}Entanglement"] = signed(b["entanglement"])
        m[f"{p}Contact"] = signed(b["contact"])
    for name, row in rows.items():
        p = prefix[name]
        m[f"{p}Neutrinos"] = str(row["right_handed_neutrinos"])
        m[f"{p}Threshold"] = fraction(row["threshold"])
        m[f"{p}ThresholdDecimal"] = sig(float(Fraction(row["threshold"])), 4)
        m[f"{p}Margin"] = fraction(row["margin"])
        m[f"{p}MarginPct"] = pct(row["margin"])
        m[f"{p}CouplingBound"] = fraction(row["coupling_bound"])
        m[f"{p}ConformalCount"] = signed(row["conformal_count"])

    scan = r["scan"]
    for g, n in scan["generation_counts"].items():
        m[f"genCount{_WORD[int(g)]}"] = signed(n)
    m["floorGenerations"] = str(scan["floor"]["least_generations"])
    (g1, h1), = scan["count_one"]["solutions"]
    m["countOneGenerations"], m["countOneDoublets"] = str(g1), str(h1)
    # The same counts spelled out, for prose; still read from results, never typed.
    m["floorGenerationsSpelled"] = _WORD[scan["floor"]["least_generations"]].lower()
    m["countOneGenerationsSpelled"] = _WORD[g1].lower()
    m["countOneDoubletsSpelled"] = _WORD[h1].lower()
    m["searchedGenerations"] = str(scan["count_one"]["searched"]["generations"])
    m["searchedDoublets"] = str(scan["count_one"]["searched"]["doublets"])
    # One further gauge vector with its ghosts: the Standard Model's count with it alone,
    # with a complex scalar to give it its mass, and the matter each one must bring.
    ext = scan["extensions"]
    m["smPlusOneBoson"] = signed(ext["one_boson"])
    m["smPlusBosonAndHiggs"] = signed(ext["one_boson_and_complex_scalar"])
    m["matterPerBoson"] = str(Fraction(ext["matter_per_boson"]))
    m["matterPerBosonSpelled"] = _WORD[int(Fraction(ext["matter_per_boson"]))].lower()

    mag = r["sensitivity"]["magnitude"]
    for profile, value in mag["moments"].items():
        name = "".join(p.capitalize() for p in profile.split("_"))
        m[f"moment{name}"] = str(int(value)) if float(value).is_integer() else sig(value, 4)
    for name, cuts in mag["cutoff_over_planck"].items():
        p = prefix[name]
        m[f"{p}CutoffLow"] = sig(min(cuts.values()), 4)
        m[f"{p}CutoffHigh"] = sig(max(cuts.values()), 4)

    content = table.load_content()
    species = table.load_species()
    sm = content.multiplicities(species, content.standard_model_generations,
                                content.standard_model_doublets)
    m["gaugeVectors"] = str(content.gauge_vectors)
    m["ghostsPerVector"] = str(sum(content.per_gauge_vector.values()))
    m["weylPerGeneration"] = str(sum(content.per_generation.values()))
    m["scalarsPerDoublet"] = str(sum(content.per_doublet.values()))
    m["smGenerations"] = str(content.standard_model_generations)
    m["smDoublets"] = str(content.standard_model_doublets)
    m["smWeyl"] = str(sm["weyl_fermion"])
    m["smScalars"] = str(sm["minimal_scalar"])
    m["smGhosts"] = str(sm["ghost"])
    m["contactPerGaugeField"] = signed_int(species["vector"].contact)

    # Each species' weight, and a gauge field's with its ghosts, from the table.
    from igc import count as _count
    ghosts = content.per_gauge_vector.get("ghost", 0)
    m["weightScalar"] = signed(_count.weight(species["minimal_scalar"]))
    m["weightWeyl"] = signed(_count.weight(species["weyl_fermion"]))
    m["weightGaugeField"] = signed(_count.weight(species["vector"])
                                   + ghosts * _count.weight(species["ghost"]))
    m["weightVector"] = signed(_count.weight(species["vector"]))
    m["weightGhost"] = signed(_count.weight(species["ghost"]))
    # The Standard Model's gauge sector (vectors and ghosts) and the rest, from results.
    by = r["count"]["branches"][next(n for n, p in prefix.items() if p == "sm")]["by_species"]
    gauge = sum(Fraction(by[s]["weight"]) for s in ("vector", "ghost"))
    m["smGaugeSector"] = signed(gauge)
    m["smNetWithoutGauge"] = signed(sum(Fraction(row["weight"]) for row in by.values()) - gauge)
    # What the matter outside the gauge sector must sum to for a count of one.
    m["countOneNeeds"] = str(int(1 - gauge))
    # The Standard Model less its Higgs scalars, and the count's slope in their common
    # curvature coupling xi (each scalar's weight is 1 - 6 xi).
    scalars = Fraction(by["minimal_scalar"]["weight"])
    m["smRestWeight"] = signed(sum(Fraction(row["weight"]) for row in by.values()) - scalars)
    m["smCouplingSlope"] = str(6 * by["minimal_scalar"]["multiplicity"])
    return m


# ---------------------------------------------------------------------- blocks
def _reference(key: str, r: dict) -> str:
    authors = ", ".join(r["authors"])
    where = r.get("journal") or r.get("publisher", "")
    parts = [f"**[{key}]** {authors}, \"{r['title']}\", {where}"]
    if r.get("volume"):
        parts.append(f" {r['volume']}")
    parts.append(f" ({r['year']})")
    if r.get("pages"):
        parts.append(f" {str(r['pages']).replace('-', '–')}")
    if r.get("eprint"):
        parts.append(f", arXiv:{r['eprint']}")
    if r.get("doi"):
        parts.append(f", doi:`{r['doi']}`")
    return "".join(parts) + "."


def blocks() -> dict[str, str]:
    """The lists a document carries whole, rendered from the registry."""
    references = table.load_references()
    conditions = ["| | Condition | Why it matters |", "| --- | --- | --- |"]
    for k, (condition, why) in claims.CONDITIONS.items():
        conditions.append(f"| **{k}** | {condition} | {why} |")

    limitations = [f"{i}. **{lim['key']}.** {lim['text']}"
                   for i, lim in enumerate(claims.LIMITATIONS, start=1)]

    inputs = []
    for c in claims.CLAIMS:
        if c["kind"] == "input":
            cites = ", ".join(f"[{k}]" for k in c["citations"])
            inputs.append(f"- {c['text'].rstrip('.')}. Cited: {cites}.")

    refs = [f"- {_reference(k, r)}" for k, r in sorted(references.items(), key=lambda kv: kv[0].casefold())
            if not r.get("self")]
    return {
        "conditionsTable": "\n".join(conditions),
        "limitationsList": "\n".join(limitations),
        "importedList": "\n".join(inputs),
        "referencesList": "\n".join(refs),
    }
