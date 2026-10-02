"""`make docs`: every generated document, from templates and the registry.

- docs-src/root/*.md -> the repository root (README.md, LIMITS.md, PROVENANCE.md);
- docs-src/docs/*.md -> docs/;
- CLAIMS.md, from src/igc/claims.py.

A template refers to a value only as `{{name}}`, filled from `emit.macros()` (numbers)
or `emit.blocks()` (lists rendered from the registry). A token with no value is an
error, never a blank. tests/test_docs.py checks the committed documents equal a fresh
render, so none can go stale.
"""
from __future__ import annotations

import pathlib
import re

from igc import claims, emit

ROOT = pathlib.Path(__file__).resolve().parents[2]
SRC = ROOT / "docs-src"
TARGETS = {SRC / "root": ROOT, SRC / "docs": ROOT / "docs"}
CLAIMS_PATH = ROOT / "CLAIMS.md"

_TOKEN = re.compile(r"\{\{\s*([A-Za-z0-9_]+)\s*\}\}")

_STATUS = {
    "lean": "Lean statements cited",
    "confirmed": "confirmed by exact computation",
    "imported": "imported",
    "cited": "cited",
    "open": "open",
    "limitation": "not claimed (a stated limitation)",
}


def fill(text: str, values: dict[str, str]) -> str:
    missing = []

    def repl(match):
        key = match.group(1)
        if key not in values:
            missing.append(key)
            return match.group(0)
        return values[key]

    out = _TOKEN.sub(repl, text)
    if missing:
        raise KeyError(f"template refers to undefined values: {sorted(set(missing))}")
    return out


def _cell(s: str) -> str:
    return s.replace("|", "\\|").replace("\n", " ")


def claims_md() -> str:
    lines = [
        "# Claims",
        "",
        "GENERATED from `src/igc/claims.py` by `make docs`; nothing here is added by hand.",
        "Each claim is the paper's own sentence. Where a check showed a sentence was wrong",
        "or overstated, it was corrected openly: the corrections, with the original wording,",
        "are listed at the end.",
        "",
        "**How to read the Lean column.** *Lean statements cited* means the statements",
        "listed build, with no `sorry` and no axioms beyond Lean's standard three, given the",
        "imported inputs below. Lean checks that each statement is proved; it does not check",
        "that the statement says what the claim says. That is for the reader to judge, and",
        "the table sets each claim beside its statements for that purpose. Where a claim's",
        "evidence is known not to carry all of it, the limits it names are stated in",
        "[`LIMITS.md`](LIMITS.md).",
        "",
        "## The conditions",
        "",
        emit.blocks()["conditionsTable"],
        "",
        "## Claims",
        "",
        "| key | claim | evidence | Lean | status |",
        "| --- | --- | --- | --- | --- |",
    ]
    for c in claims.CLAIMS:
        if c["kind"] != "claim":
            continue
        lean = "<br>".join(f"`{n}`" for n in c["lean"]) or "--"
        status = _STATUS[c["status"]]
        if c.get("limited_by"):
            status += "; limits: " + ", ".join(c["limited_by"])
        lines.append(f"| `{c['key']}` | {_cell(c['text'])} | {_cell(c['evidence'])} | "
                     f"{lean} | {status} |")
    lines += ["", "## What is imported", "", "| key | input | cited | consumed as |",
              "| --- | --- | --- | --- |"]
    for c in claims.CLAIMS:
        if c["kind"] == "input":
            cites = ", ".join(c["citations"])
            lines.append(f"| `{c['key']}` | {_cell(c['text'])} | {cites} | {_cell(c['script'])} |")
    lines += ["", "## Corrections", ""]
    for c in claims.CLAIMS:
        if "original" in c:
            lines += [f"- **`{c['key']}`.** {c['correction']}",
                      f"  - First worded: \"{c['original']}\""]
    for k, (original, reason) in claims.CONDITION_CORRECTIONS.items():
        lines += [f"- **{k}'s motivation.** {reason}", f"  - First worded: \"{original}\""]
    counts: dict[str, int] = {}
    for c in claims.CLAIMS:
        if c["kind"] == "claim":
            counts[c["status"]] = counts.get(c["status"], 0) + 1
    lines += ["", "Summary: " + ", ".join(f"{n} {_STATUS[s]}" for s, n in sorted(counts.items()))
              + "."]
    return "\n".join(lines) + "\n"


def render_all() -> dict[pathlib.Path, str]:
    values = {**emit.macros(), **emit.blocks()}
    out = {}
    for src_dir, dest_dir in TARGETS.items():
        for src in sorted(src_dir.glob("*.md")):
            out[dest_dir / src.name] = fill(src.read_text(encoding="utf-8"), values)
    out[CLAIMS_PATH] = claims_md()
    return out


def write_all() -> list[pathlib.Path]:
    written = []
    for path, text in render_all().items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        written.append(path)
    return written


if __name__ == "__main__":
    for p in write_all():
        print(f"wrote {p.relative_to(ROOT)}")
