"""The LaTeX feed: every value a valid command, every table read from results, every
reference in refs.bib. The feed is not committed (it regenerates from results/), so
these check `igc.latex`'s output directly.

Compiling the test document needs a TeX installation, so it runs only when asked
(`IGC_LATEX=1`) and `latexmk` is on PATH; `make paper-test` is the usual route.
"""
import json
import os
import pathlib
import re
import shutil
import subprocess
from fractions import Fraction

import pytest

from igc import emit, latex, table

ROOT = pathlib.Path(__file__).resolve().parents[1]
COUNT = json.loads((ROOT / "results" / "count.json").read_text(encoding="utf-8"))

_COMMAND = re.compile(r"^\\newcommand\{\\([A-Za-z]+)\}\{(.*)\}$")
_UNESCAPED_PERCENT = re.compile(r"(?<!\\)%")


@pytest.fixture(scope="module")
def macros():
    return emit.macros()


@pytest.fixture(scope="module")
def numbers(macros):
    return latex.numbers_tex(macros)


def test_one_command_per_macro(numbers, macros):
    defined = [m.group(1) for line in numbers.splitlines() if (m := _COMMAND.match(line))]
    assert sorted(defined) == sorted(macros)


def test_values_are_tex_safe(numbers):
    for line in numbers.splitlines():
        if line.startswith("%") or not line:
            continue
        value = _COMMAND.match(line).group(2)
        assert "−" not in value, f"raw typographic minus in {line}"
        assert not _UNESCAPED_PERCENT.search(value), f"unescaped % in {line}"


def test_names_must_be_letters():
    with pytest.raises(ValueError):
        latex.latex_safe_name("net0Generations")


def test_count_table_totals_are_the_results():
    sm = next(b for b in COUNT["branches"].values() if b["by_species"]["weyl_fermion"]["multiplicity"] == 45)
    text = latex.tables()["count"]
    totals = next(line for line in text.splitlines() if line.startswith("Total"))
    for key in ("K", "I", "net", "entanglement", "contact"):
        cell = "$" + emit.signed(Fraction(sm[key])).replace("−", "-") + "$"
        assert cell in totals, f"count table total for {key} is not {cell}"


def test_every_table_names_its_float():
    for name, text in latex.tables().items():
        assert text.splitlines()[0] in ("% float: table", "% float: table*"), name


def test_bib_has_every_reference():
    bib = latex.refs_bib()
    for key in table.load_references():
        assert re.search(rf"^@\w+\{{{re.escape(key)},$", bib, re.MULTILINE), key


def test_documents_cite_only_known_keys():
    keys = set(table.load_references())
    related = (ROOT / "docs" / "related-work.md").read_text(encoding="utf-8")
    cited = set(re.findall(r"\*\*\[([A-Za-z0-9]+)\]\*\*", related))
    assert cited and cited <= keys, f"cited but not in references.yaml: {cited - keys}"


@pytest.mark.skipif(os.environ.get("IGC_LATEX") != "1" or not shutil.which("latexmk"),
                    reason="set IGC_LATEX=1 with a TeX installation to compile the test document")
def test_test_document_compiles_cleanly():
    latex.write_all()
    test_dir = ROOT / "paper" / "test"
    subprocess.run(["latexmk", "-pdf", "-interaction=nonstopmode", "-halt-on-error",
                    "minimal.tex"], cwd=test_dir, check=True, capture_output=True)
    log = (test_dir / "minimal.log").read_text(encoding="utf-8", errors="replace")
    for bad in ("Overfull", "undefined", "Font Warning"):
        assert bad not in log, f"minimal.log reports {bad}"
