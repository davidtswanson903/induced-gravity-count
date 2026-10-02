.PHONY: all data lean count scan sensitivity latex figures docs test paper-test paper clean

PYTHON ?= python

all: data lean count scan sensitivity latex figures docs test

data:
	$(PYTHON) -m igc.codegen

lean:
	cd lean && lake build

count:
	$(PYTHON) experiments/run_count.py

scan:
	$(PYTHON) experiments/run_scan.py

sensitivity:
	$(PYTHON) experiments/run_sensitivity.py

latex:
	$(PYTHON) -m igc.latex

figures:
	$(PYTHON) experiments/figures.py

docs:
	$(PYTHON) -m igc.docs

test:
	$(PYTHON) -m pytest tests/ -q

# Compiles paper/test/minimal.tex against the feed: proof the feed builds under the
# paper's class. Not part of `make all`, which needs no TeX installation.
paper-test: latex figures
	cd paper/test && latexmk -pdf -interaction=nonstopmode -halt-on-error minimal.tex

# Compiles the draft, paper/draft/paper.tex, against the feed.
paper: latex figures
	cd paper/draft && latexmk -pdf -interaction=nonstopmode -halt-on-error paper.tex

clean:
	rm -rf results/*.json build/figures/*.pdf build/latex/*.tex build/latex/tables/* build/latex/refs.bib
	cd paper/test && latexmk -C minimal.tex
	cd paper/draft && latexmk -c paper.tex
