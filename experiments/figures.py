"""`make figures`: the paper's two figures, read only from results/*.json, written to
build/figures/ as PDF (for the paper) and PNG (committed, for browsing).

- generations: the count against the number of generations, with one Higgs doublet --
  negative below three, positive from three on. Bars are blue where gravity attracts and
  red where it does not; each bar's direction carries the sign as well.
- criterion: the count against the insertion's weighting rho, for each neutrino content.
  Each line crosses zero at its content's threshold; the cutoff of K1 gives rho = 6.

Palettes are validated (the blue/red polarity pair, and the first three categorical
slots, all pairs) with the data-visualization validator; the aqua slot sits below 3:1
contrast on white, so every line is labelled directly.
"""
from __future__ import annotations

import json
import pathlib
from fractions import Fraction

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parents[1]
RESULTS = ROOT / "results"
OUT = ROOT / "build" / "figures"

INK, INK_2, GRID, SURFACE = "#0b0b0b", "#52514e", "#e4e3df", "#ffffff"
ATTRACTS, REPELS = "#2a78d6", "#e34948"
SERIES = ["#2a78d6", "#eb6834", "#1baf7a"]
WIDTH = 3.4  # inches: one column of a two-column page

plt.rcParams.update({
    "font.size": 8, "axes.edgecolor": INK_2, "axes.labelcolor": INK, "xtick.color": INK_2,
    "ytick.color": INK_2, "axes.spines.top": False, "axes.spines.right": False,
    "figure.facecolor": SURFACE, "axes.facecolor": SURFACE, "savefig.facecolor": SURFACE,
    "legend.frameon": False,
})


def _load(name: str) -> dict:
    return json.loads((RESULTS / f"{name}.json").read_text(encoding="utf-8"))


def _save(fig, name: str) -> list[pathlib.Path]:
    OUT.mkdir(parents=True, exist_ok=True)
    paths = [OUT / f"{name}.pdf", OUT / f"{name}.png"]
    fig.savefig(paths[0], bbox_inches="tight")
    fig.savefig(paths[1], bbox_inches="tight", dpi=200)
    plt.close(fig)
    return paths


def _signed(n: int) -> str:
    return f"+{n}" if n > 0 else ("−" + str(-n) if n < 0 else "0")


def generations() -> list[pathlib.Path]:
    counts = {int(g): Fraction(n) for g, n in _load("scan")["counts_to_six_generations"].items()}
    gs = sorted(counts)
    values = [float(counts[g]) for g in gs]
    colors = [ATTRACTS if v > 0 else REPELS for v in values]
    fig, ax = plt.subplots(figsize=(WIDTH, 2.3))
    ax.grid(axis="y", color=GRID, linewidth=0.6)
    ax.set_axisbelow(True)
    ax.bar(gs, values, width=0.55, color=colors, edgecolor=SURFACE, linewidth=1.0)
    ax.axhline(0, color=INK_2, linewidth=0.8)
    span = max(values) - min(values)
    for g, v, c in zip(gs, values, colors):
        if abs(v) < 0.03 * span:  # too short to see as a bar: mark its end
            ax.plot([g], [v], marker="o", markersize=5, color=c, markeredgecolor=SURFACE,
                    markeredgewidth=1.0, zorder=3)
    for g, v in zip(gs, values):
        offset = 0.04 * span if v >= 0 else -0.04 * span
        ax.text(g, v + offset, _signed(int(v)), ha="center",
                va="bottom" if v >= 0 else "top", color=INK, fontsize=7)
    ax.set_xticks(gs)
    ax.set_xlabel("Generations (one Higgs doublet)")
    ax.set_ylabel("Net count")
    ax.set_ylim(min(values) - 0.18 * span, max(values) + 0.18 * span)
    handles = [plt.Rectangle((0, 0), 1, 1, color=ATTRACTS), plt.Rectangle((0, 0), 1, 1, color=REPELS)]
    ax.legend(handles, ["attracts", "does not attract"], loc="upper left", fontsize=7)
    return _save(fig, "generations")


def criterion() -> list[pathlib.Path]:
    count = _load("count")["branches"]
    rows = _load("sensitivity")["neutrino_rows"]
    rho_lo, rho_hi, rho_axis = 5.5, 6.2, 6.55  # lines end at rho_hi; labels sit after them
    fig, ax = plt.subplots(figsize=(WIDTH, 2.5))
    ax.grid(axis="y", color=GRID, linewidth=0.6)
    ax.set_axisbelow(True)
    ax.axhline(0, color=INK_2, linewidth=0.8)
    ax.axvline(6, color=INK_2, linewidth=0.8, linestyle=(0, (3, 2)))
    ax.text(6, 1.0, " K1: ρ = 6", color=INK, fontsize=7, va="bottom", ha="left",
            transform=ax.get_xaxis_transform())
    for color, (name, row) in zip(SERIES, rows.items()):
        K, I = float(Fraction(count[name]["K"])), float(Fraction(count[name]["I"]))
        n = row["right_handed_neutrinos"]
        label = "no right-handed ν" if n == 0 else f"{n} right-handed ν"
        xs = [rho_lo, rho_hi]
        ax.plot(xs, [K + x / 6 * I for x in xs], color=color, linewidth=2, label=label)
        t = float(Fraction(row["threshold"]))
        ax.plot([t], [0], marker="o", markersize=5, color=color,
                markeredgecolor=SURFACE, markeredgewidth=1.0, zorder=3)
        ax.text(rho_hi + 0.02, K + rho_hi / 6 * I, f"{n} ν$_R$", color=INK, fontsize=7,
                va="center")
        if n == 0:
            ax.annotate(f"{row['threshold']} ≈ {t:.3f}", xy=(t, 0), xytext=(t, -2.2),
                        ha="center", fontsize=7, color=INK,
                        arrowprops={"arrowstyle": "-", "color": INK_2, "linewidth": 0.6})
    ax.set_xlim(rho_lo, rho_axis)
    ax.set_xticks([5.6, 5.8, 6.0, 6.2])
    ax.set_xlabel("Insertion's weighting ρ")
    ax.set_ylabel("Net count")
    ax.legend(loc="upper left", fontsize=7)
    return _save(fig, "criterion")


if __name__ == "__main__":
    for p in generations() + criterion():
        print(f"wrote {p.relative_to(ROOT)}")
