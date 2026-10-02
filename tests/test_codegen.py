"""Nobody edits lean/IGC/Generated/*.lean by hand. Both files must be byte-identical
to a fresh regeneration -- which catches a stale species.yaml *and* a changed
count.py/horizon.py (Expected.lean is Python's computed values) -- and Table.lean's
embedded hash must match species.yaml, the check a reader of the Lean file can make
without Python. Regenerate with `make data`.
"""
import re

from igc import codegen


def test_table_hash_matches_species_yaml():
    text = codegen.TABLE_PATH.read_text(encoding="utf-8")
    match = re.search(r'tableHash : String := "([0-9a-f]+)"', text)
    assert match, "lean/IGC/Generated/Table.lean has no tableHash constant"
    assert match.group(1) == codegen._species_hash(), (
        "Table.lean is stale against data/species.yaml -- run `make data`"
    )


def test_table_matches_regeneration():
    assert codegen.TABLE_PATH.read_text(encoding="utf-8") == codegen.generate_table()


def test_expected_matches_regeneration():
    assert codegen.EXPECTED_PATH.read_text(encoding="utf-8") == codegen.generate_expected(), (
        "Expected.lean is stale against species.yaml or count.py/horizon.py -- run `make data`"
    )
