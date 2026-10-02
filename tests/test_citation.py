"""The archive's metadata agrees with the package and with the paper's self-citation:
one title, one version, one author record, so the Zenodo record, CITATION.cff and the
bibliography cannot drift apart.
"""
import json
import pathlib
import re
import tomllib

from igc import table

ROOT = pathlib.Path(__file__).resolve().parents[1]
ORCID = "0009-0003-0580-6476"


def _cff() -> dict[str, str]:
    """The top-level scalar fields of CITATION.cff."""
    return dict(re.findall(r'^(\w[\w-]*): "?([^"\n>]+?)"?\s*$',
                           (ROOT / "CITATION.cff").read_text(encoding="utf-8"), re.MULTILINE))


def test_zenodo_cff_bibliography_and_package_agree():
    zenodo = json.loads((ROOT / ".zenodo.json").read_text(encoding="utf-8"))
    cff = _cff()
    ref = table.load_references()["SwansonIGC"]
    version = tomllib.loads((ROOT / "pyproject.toml").read_text(encoding="utf-8"))["project"]["version"]
    assert zenodo["title"] == cff["title"] == ref["title"]
    assert zenodo["version"] == cff["version"] == ref["version"] == version
    assert zenodo["license"] == cff["license"] == "MIT"
    assert zenodo["creators"][0]["orcid"] == ORCID
    assert ORCID in (ROOT / "CITATION.cff").read_text(encoding="utf-8")
    assert cff["repository-code"] == ref["url"]
    assert zenodo["upload_type"] == "software"


def test_self_citation_is_cited_and_kept_out_of_related_work():
    assert "\cite{SwansonIGC}" in (ROOT / "paper" / "draft" / "paper.tex").read_text(encoding="utf-8")
    assert "SwansonIGC" not in (ROOT / "docs" / "related-work.md").read_text(encoding="utf-8")
