"""Claim keys: every `% claim: <key>` marker in a paper .tex source resolves to a
current key in igc.claims.CLAIMS. Claims are cited by a stable string key rather than
a position, so inserting one cannot silently shift the citations after it; this test
is what checks the keys rather than leaving it to hand.
"""
import pathlib
import re

from igc.claims import CLAIMS

ROOT = pathlib.Path(__file__).resolve().parents[1]

# A result is marked `\claim{key}` in the paper's source (or by a `% claim: key` comment).
_CLAIM_RE = re.compile(r"(?:%\s*claim:\s*|\\claim\{)([a-z0-9][a-z0-9-]*)")


def test_every_tex_claim_citation_resolves():
    keys = {c["key"] for c in CLAIMS}
    tex_files = sorted((ROOT / "paper").rglob("*.tex"))
    unresolved = []
    for path in tex_files:
        text = path.read_text(encoding="utf-8")
        for cited in _CLAIM_RE.findall(text):
            if cited not in keys:
                unresolved.append((path.relative_to(ROOT), cited))
    assert not unresolved, (
        f"claim citations with no matching key in igc.claims.CLAIMS: {unresolved}"
    )
