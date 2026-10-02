"""Reading the Lean development's declarations from source: every theorem's statement and
every definition, by fully qualified name, with comments and docstrings stripped.

The claims registry cites theorems by name; tests/test_claims.py checks each name is a
theorem here and in lean/Audit.lean's axiom audit.
"""
from __future__ import annotations

import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[2]
LEAN_DIR = ROOT / "lean" / "IGC"

_BLOCK_COMMENT = re.compile(r"/-.*?-/", re.DOTALL)
_LINE_COMMENT = re.compile(r"--[^\n]*")
_START = re.compile(
    r"^(?:@\[[^\]]*\]\s*)?(?:(?:private|protected|noncomputable|local)\s+)*"
    r"(theorem|lemma|def|abbrev|structure|instance|macro|namespace|end|open|import|"
    r"variable|section)\b\s*([^\s:({\[]*)",
    re.MULTILINE,
)
_DEFINITIONS = {"def", "abbrev", "structure"}


def _strip_comments(text: str) -> str:
    return _LINE_COMMENT.sub("", _BLOCK_COMMENT.sub("", text))


def _normalize(text: str) -> str:
    return " ".join(text.split())


def lean_declarations(display: bool = False) -> tuple[dict[str, str], dict[str, str]]:
    """(theorems, definitions), each keyed by fully qualified name. A theorem maps to
    its statement alone (up to `:=`); a definition to its whole text. Either is preceded
    by the `variable` declarations in scope where it is stated, since a statement
    without its variables is incomplete. Comments and docstrings are gone from both;
    instances and macros are left out. `display` keeps line breaks for reading; the
    default collapses whitespace, so two versions compare by content."""
    shape = (lambda s: "\n".join(line.rstrip() for line in s.strip().splitlines() if line.strip())) \
        if display else _normalize
    theorems: dict[str, str] = {}
    definitions: dict[str, str] = {}
    for path in sorted(LEAN_DIR.rglob("*.lean")):
        code = _strip_comments(path.read_text(encoding="utf-8"))
        starts = list(_START.finditer(code))
        # Each open namespace or section, with the variables declared in it.
        scopes: list[tuple[str, str, list[str]]] = [("file", "", [])]
        for i, m in enumerate(starts):
            kind, name = m.group(1), m.group(2)
            chunk = code[m.start(): starts[i + 1].start() if i + 1 < len(starts) else len(code)]
            if kind in ("namespace", "section"):
                scopes.append((kind, name, []))
                continue
            if kind == "end":
                if len(scopes) > 1 and name == scopes[-1][1]:
                    scopes.pop()
                continue
            if kind == "variable":
                scopes[-1][2].append(chunk.strip())
                continue
            namespace = [n for k, n, _ in scopes if k == "namespace"]
            full = ".".join(namespace + [name])
            context = [v for _, _, vs in scopes for v in vs]
            if kind in ("theorem", "lemma"):
                theorems[full] = shape("\n".join(context + [chunk.split(":=", 1)[0]]))
            elif kind in _DEFINITIONS and name != "tableHash":
                # tableHash only stamps which species.yaml the table came from.
                definitions[full] = shape("\n".join(context + [chunk]))
    return theorems, definitions
