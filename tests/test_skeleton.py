"""The package imports, and the repository's layout exists."""
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]


def test_package_imports():
    import igc  # noqa: F401


def test_layout_exists():
    for rel in (
        "data", "src/igc", "experiments", "tests", "results",
        "build/latex", "build/figures", "docs-src", "docs", "paper", "lean",
    ):
        assert (ROOT / rel).is_dir(), f"missing directory: {rel}"
