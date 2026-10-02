"""The numbers rule: every scientific-notation value, percentage, or explicitly-signed
integer appearing in a generated document must be traceable to `igc.emit.macros()`,
i.e. to results/.

This does not catch every possible hand-typed numeral -- an unsigned integer ("63"
rather than "+63"), or a plain decimal in prose -- that limitation is stated here
rather than hidden. What it does catch is exactly the category this
house style always uses for a computed value: scientific notation, decimal
percentages, and explicitly-signed integers (`igc.emit.signed_int`). Those
appearing in a generated document that do NOT match a current macro value are either
stale (the doc was not regenerated after the results changed) or hand-typed, and
either way this test should fail.
"""
import re

import pytest

from igc import emit

_SCI_RE = re.compile(r"-?\d[\d,]*\.?\d*e[+-]\d+")
_PCT_RE = re.compile(r"-?\d+\.\d+\\?%")
_SIGNED_INT_RE = re.compile(r"[+−-]\d+")

# Not prose: fenced code blocks, inline code spans, and link targets (paths, DOIs and
# URLs, whose hyphens and digits are not quoted values).
_NOT_PROSE = re.compile(r"```.*?```|`[^`\n]*`|\]\([^)]*\)|https?://\S+", re.DOTALL)

GENERATED_DOCS = emit.GENERATED_DOCS


@pytest.fixture(scope="module")
def macro_values():
    return set(emit.macros().values())


def quoted_numbers(text: str) -> list[str]:
    """The computed-value-shaped tokens in a document's prose."""
    prose = _NOT_PROSE.sub(" ", text)
    return _SCI_RE.findall(prose) + _PCT_RE.findall(prose) + _SIGNED_INT_RE.findall(prose)


@pytest.mark.parametrize("doc", GENERATED_DOCS, ids=lambda p: p.name)
def test_numbers_trace_to_a_macro(doc, macro_values):
    if not doc.exists():
        pytest.skip(f"{doc} not yet generated -- run `make docs` first")
    text = doc.read_text(encoding="utf-8")
    found = quoted_numbers(text)
    untraceable = [tok for tok in found if tok not in macro_values]
    assert not untraceable, (
        f"{doc.name} contains values not found among the current macros() output "
        f"(stale doc, or a hand-typed number): {untraceable}"
    )
