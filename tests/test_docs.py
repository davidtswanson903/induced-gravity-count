"""The generated documents: current, and quoting only computed values.

- Every committed document equals a fresh render (igc.docs), so none goes stale when a
  result, the registry or a template changes.
- CLAIMS.md quotes the paper's own sentences, so it is not filled from macros; instead
  every computed-value-shaped number in a claim's text -- a signed count, a per-cent
  figure -- must be one the results currently produce. A sentence quoting a number the
  build no longer produces fails here.
"""
import re

import pytest

from igc import claims, docs, emit

_PER_CENT = re.compile(r"(\d+\.\d+) per cent")
_SIGNED_INT = re.compile(r"[+−]\d+")


@pytest.fixture(scope="module")
def rendered():
    return docs.render_all()


def test_committed_documents_are_current(rendered):
    for path, text in rendered.items():
        assert path.exists(), f"{path.name} not generated -- run `make docs`"
        assert path.read_text(encoding="utf-8") == text, (
            f"{path.name} differs from a fresh render -- run `make docs`"
        )


def test_claims_quote_only_computed_numbers():
    values = set(emit.macros().values())
    for c in claims.CLAIMS:
        if c["kind"] != "claim":
            continue
        for tok in _SIGNED_INT.findall(c["text"]):
            assert tok in values, f"{c['key']}: quotes {tok}, which no result produces"
        for tok in _PER_CENT.findall(c["text"]):
            assert f"{tok}%" in values, f"{c['key']}: quotes {tok} per cent, which no result produces"


def test_every_document_names_its_source(rendered):
    for path, text in rendered.items():
        assert "GENERATED from" in text.split("\n\n", 2)[1] or "GENERATED from" in text[:400], (
            f"{path.name} does not say it is generated"
        )
