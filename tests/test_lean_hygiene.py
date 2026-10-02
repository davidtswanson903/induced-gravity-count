"""Lean hygiene: no `sorry`, no `native_decide`, no declared axioms, and no
wholesale `import Mathlib` anywhere in the Lean sources. Runs in the Python CI, so a
violation is caught even where the Lean job is skipped. Comments are stripped first, so
prose that mentions these words (docstrings explaining why there are none) does not
count.

The axioms the theorems actually depend on are checked separately, by
`lake env lean Audit.lean` in .github/workflows/lean.yml.
"""
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
LEAN = ROOT / "lean"

_BLOCK_COMMENT = re.compile(r"/-.*?-/", re.DOTALL)
_LINE_COMMENT = re.compile(r"--[^\n]*")

_FORBIDDEN = {
    "sorry": re.compile(r"\bsorry\b"),
    "native_decide": re.compile(r"\bnative_decide\b"),
    "a declared axiom": re.compile(r"^\s*(?:private\s+|protected\s+)?axiom\b", re.MULTILINE),
    "a wholesale `import Mathlib`": re.compile(r"^\s*import\s+Mathlib\s*$", re.MULTILINE),
}


def _lean_sources():
    return sorted(p for p in LEAN.rglob("*.lean") if ".lake" not in p.parts)


def _code(text: str) -> str:
    return _LINE_COMMENT.sub("", _BLOCK_COMMENT.sub("", text))


def test_there_are_lean_sources():
    assert _lean_sources(), "no Lean sources found under lean/"


def test_no_forbidden_constructs():
    found = []
    for path in _lean_sources():
        code = _code(path.read_text(encoding="utf-8"))
        for name, pattern in _FORBIDDEN.items():
            if pattern.search(code):
                found.append(f"{path.relative_to(ROOT)}: {name}")
    assert not found, "\n".join(found)
