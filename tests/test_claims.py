"""The claims registry (src/igc/claims.py): every cited Lean theorem exists and is in the
axiom audit, every status is one the registry defines, every limitation is named, used
and cited, every correction keeps its original wording, and every input is cited.
"""
import pathlib
import re

from igc import claims, leansrc, table

ROOT = pathlib.Path(__file__).resolve().parents[1]
AUDIT = (ROOT / "lean" / "Audit.lean").read_text(encoding="utf-8")

_CLAIM_STATUSES = {"lean", "confirmed", "cited", "open", "limitation"}


def test_cited_theorems_exist_and_are_audited():
    theorems, _ = leansrc.lean_declarations()
    for c in claims.CLAIMS:
        for name in c["lean"]:
            assert name in theorems, f"{c['key']}: cites {name}, which is not in lean/IGC"
            assert re.search(rf"^#print axioms {re.escape(name)}\s*$", AUDIT, re.MULTILINE), (
                f"{c['key']}: {name} is not in lean/Audit.lean's axiom audit"
            )


def test_statuses():
    for c in claims.CLAIMS:
        if c["kind"] == "input":
            continue
        assert c["status"] in _CLAIM_STATUSES, f"{c['key']}: unknown status {c['status']!r}"
        assert (c["status"] == "lean") == bool(c["lean"]), (
            f"{c['key']}: status 'lean' exactly when the claim cites Lean statements"
        )


def test_limitations_are_named_used_and_cited():
    references = table.load_references()
    keys = [lim["key"] for lim in claims.LIMITATIONS]
    assert len(keys) == len(set(keys)), "duplicate limitation key"
    used = set()
    for c in claims.CLAIMS:
        for k in c.get("limited_by", []):
            assert k in keys, f"{c['key']}: names limitation {k!r}, not in claims.LIMITATIONS"
            used.add(k)
        if c["status"] == "limitation":
            assert not c["lean"] and c.get("limited_by"), (
                f"{c['key']}: a row not claimed must cite no Lean and name its limitation"
            )
    assert set(keys) <= used, f"limitations bounding no claim: {set(keys) - used}"
    for lim in claims.LIMITATIONS:
        for r in lim["citations"]:
            assert r in references, f"limitation {lim['key']}: cites {r}, not in references"


def test_corrected_rows_keep_their_original():
    for c in claims.CLAIMS:
        assert ("original" in c) == ("correction" in c), (
            f"{c['key']}: a correction needs both the original text and the reason"
        )
        if "original" in c:
            assert c["original"] != c["text"], f"{c['key']}: 'original' equals 'text'"
    for k, (original, reason) in claims.CONDITION_CORRECTIONS.items():
        assert k in claims.CONDITIONS and original != claims.CONDITIONS[k][1] and reason, k


def test_inputs_are_cited():
    references = table.load_references()
    for c in claims.CLAIMS:
        if c["kind"] == "input":
            assert c["status"] in {"imported", "cited"}, c["key"]
            assert c["citations"], f"{c['key']}: an input with no citation"
            for r in c["citations"]:
                assert r in references, f"{c['key']}: cites {r}, not in data/references.yaml"
