"""The claims registry: one row per claim, each with a stable string key. CLAIMS.md is
generated from this list; nothing is added to CLAIMS.md that is not added here.

Two kinds of row:
    claim  -- the paper's own sentence or clause, verbatim. Never reworded to fit what
              was proved: if a check shows a claim can only be stated more weakly, or
              that it is worded wrongly, the claim is corrected openly, keeping the
              original and naming the clause that changed.
    input  -- what this repository consumes from the literature, named as such.

Each row:
    key        a stable string, never renumbered or reused
    kind       "claim" or "input"
    text       the sentence or clause (corrected, where a correction was made)
    original   the sentence as first written (corrected claims only)
    correction which clause changed, and why (corrected claims only)
    evidence   what backs it
    script     what produces or checks it
    lean       fully qualified Lean theorems it cites (claims only; may be empty)
    citations  reference keys in data/references.yaml (inputs, and cited claims)
    limited_by keys in LIMITATIONS that bound the claim (optional): what the claim's
               evidence does not carry, stated for the reader
    status     lean            -- cites Lean statements, which build with no sorry and no
                                  axioms beyond the standard three. Whether a statement
                                  carries the claim as worded is the reader's judgement,
                                  not a status this repository assigns itself
               confirmed       -- exact computation against frozen fixtures, no Lean
               limitation      -- not claimed by this paper; kept as the motivation it
                                  gives, with the limitation that bounds it
               imported / cited / open

Claims are cited by key, never by position, so inserting one moves no other citation;
tests/test_claim_keys.py checks every `% claim: <key>` marker in paper/*.tex.
"""

# The four conditions: each condition, and why it matters, in the paper's wording.
# CONDITION_CORRECTIONS records each change of substance, keeping the first wording;
# a change of wording alone is not recorded.
CONDITIONS: dict[str, tuple[str, str]] = {
    "K1": (
        "The cutoff is spectral, taken in the fluctuation operator, with its profile "
        "normalized to the heat kernel's",
        "Under this cutoff the kinetic part and the curvature insertion stand at one to "
        "six for every profile. A cutoff taken in another operator transfers a share of "
        "that operator's curvature, and the ratio is lost",
    ),
    "K2": (
        "One loop, with the gauge fields counted as species at the cutoff, each with its "
        "contact term",
        "The contact term is what reconciles the induced coupling with horizon entropy",
    ),
    "K3": (
        "The static coefficient only. The paper claims Newton's constant, not an induced "
        "graviton sector",
        "With a regulator that is not Lorentz-invariant, an induced action's time and "
        "space derivative terms need not agree, so a dynamical claim would need more "
        "than a static one",
    ),
    "K4": (
        "The vacuum energy is not addressed. The cosmological term is set aside, and the "
        "count concerns the curvature term alone",
        "The cosmological term is the cutoff trace's leading order and the curvature term "
        "the next, so the count neither needs the vacuum energy nor says anything about it",
    ),
}

# Each changed condition: the text as first written, and which clause changed and why.
CONDITION_CORRECTIONS: dict[str, tuple[str, str]] = {
    "K1": (
        "Under this cutoff the kinetic part and the curvature insertion stand at one to "
        "six for every profile. A cutoff taken in another operator transfers a "
        "profile-dependent share of that operator's curvature, and the ratio is lost",
        "'a profile-dependent share' became 'a share'. A cutoff in another operator is "
        "not modelled here (limitation other-operator), and the one model at hand gives "
        "a transferred share that does not depend on the profile.",
    ),
}

# What this paper does not establish, stated as its limits. A claim names the
# limitations that bound it (`limited_by`).
LIMITATIONS: list[dict] = [
    dict(
        key="profile-scope",
        text="The induced coefficient's expansion in the profile's moment is proved here "
             "for proper-time profiles: Laplace transforms of finite measures carried by a "
             "bounded proper-time interval. For other profiles it is imported where the "
             "literature states it, for Laplace-transform and for Schwartz profiles. The "
             "Schwinger proper-time cutoff, whose proper-time measure is infinite, would "
             "need a spectral gap and is not covered.",
        citations=["vanSuijlekom2024", "EcksteinIochum2018", "EstradaGraciaBondiaVarilly1998"],
    ),
    dict(
        key="sharp-cutoff-in-mean",
        text="For the sharp cutoff the moments obey the integration-by-parts identity "
             "exactly, so its weighting is six. But its cutoff trace has no expansion "
             "beyond the leading term except in the Cesàro sense, so for the sharp step "
             "the induced coefficient is defined only as a mean.",
        citations=["EstradaGraciaBondiaVarilly1998", "EcksteinIochum2018"],
    ),
    dict(
        key="constant-insertion",
        text="The second reading of the one-to-six, as the cutoff trace's first-order "
             "response to the curvature insertion, is formalized for an insertion that "
             "shifts the spectrum by a constant. A position-dependent insertion would need "
             "the operator's perturbation theory. The induced coefficient does not rest on "
             "this reading: it uses the heat kernel's coefficient for the full operator.",
        citations=["Vassilevich2003"],
    ),
    dict(
        key="induced-premise",
        text="The constraints on content hold only if Newton's constant is entirely induced "
             "by the species below the cutoff, with no bare term: Sakharov's premise, which "
             "this repository does not argue for. With a bare term, the count gives only the "
             "sign of matter's contribution to 1/G. The constraints concern the complete "
             "content below a cutoff of a few Planck masses, so the matter that pays for a "
             "gauge boson may lie anywhere below it: they constrain complete models, and no "
             "single discovery tests them.",
        citations=["Sakharov1967"],
    ),
    dict(
        key="other-operator",
        text="A cutoff taken in an operator other than the fluctuation operator is not "
             "modelled. K1's contrast with such a cutoff is the condition's motivation, "
             "not a result of this paper.",
        citations=[],
    ),
]

_FIXTURE = "tests/fixtures/count_equivalence.json, checked by tests/test_count_equivalence.py"

CLAIMS: list[dict] = [
    # --- the headline ---------------------------------------------------------------
    dict(
        key="induced-newton-constant-positive",
        kind="claim",
        text="Under a spectral cutoff taken in the fluctuation operator itself, the "
             "Standard Model's induced Newton constant, with the Higgs minimally coupled, "
             "is positive.",
        original="Under a spectral cutoff taken in the fluctuation operator itself, the "
                 "Standard Model's induced Newton constant is positive.",
        correction="', with the Higgs minimally coupled,' was added. With the Higgs "
                   "doublet at a common curvature coupling ξ the sign holds exactly when "
                   "ξ < 1/24 (IGC.sm_coupled_newton), so unqualified the claim overstated.",
        evidence="the Standard Model's regulated one-loop action, each species cut in its "
                 "own operator, induces a Newton constant, and every one it induces is "
                 "positive; proved from the heat trace alone for proper-time profiles, and "
                 "for other profiles from the imported spectral-action expansion, with no "
                 "hypothesis on the moment for non-increasing profiles",
        script="lean/IGC/StandardModel.lean; lean/IGC/InducedNewton.lean",
        lean=["IGC.sm_newton_positive", "IGC.sm_newton_positive_properTime",
              "IGC.sm_newton_positive_monotone", "IGC.ProperTimeProfile.spectralActionA1",
              "IGC.InducesNewton.unique", "IGC.attractive_iff"],
        limited_by=["profile-scope", "sharp-cutoff-in-mean"],
        status="lean",
    ),
    dict(
        key="headline-count",
        kind="claim",
        text="In units of one minimally coupled scalar, the kinetic parts sum to −62 and "
             "the curvature insertions to +63, a net of +1.",
        evidence="evaluated exactly over the generated Standard Model content; "
                 "Python and Lean agree",
        script="lean/IGC/StandardModel.lean; experiments/run_count.py",
        lean=["IGC.sm_kinetic", "IGC.sm_insertion", "IGC.sm_net"],
        status="lean",
    ),
    dict(
        key="sign-profile-independent",
        kind="claim",
        text="The ratio between the two is one to six for every cutoff profile, so the "
             "sign does not depend on the profile.",
        evidence="the induced coefficient of any content is the profile's normalized "
                 "moment times a fixed factor times the net count, so the profile enters "
                 "as one positive factor; the kinetic part and the insertion stand at one "
                 "to six for every proper-time profile, and the insertion's weighting is "
                 "six for every profile of bounded variation, the sharp step included",
        script="lean/IGC/InducedNewton.lean; lean/IGC/OneToSix.lean; lean/IGC/Profile.lean",
        lean=["IGC.inducesNewton_of_spectralAction", "IGC.inducesNewton_properTime",
              "IGC.ProperTimeProfile.normalizedMoment_pos",
              "IGC.normalizedMoment_pos_ofMeasure", "IGC.one_to_six",
              "IGC.Profile.weighting_eq_six"],
        limited_by=["profile-scope", "sharp-cutoff-in-mean"],
        status="lean",
    ),
    dict(
        key="horizon-independent-route",
        kind="claim",
        text="The horizon entropy count gives the same +1 by a second route: "
             "entanglement 73, less the gauge fields' contact term of 72.",
        original="The horizon entropy count gives the same +1 by an independent route: "
                 "entanglement 73, less the gauge fields' contact term of 72.",
        correction="'by an independent route' became 'by a second route'. The two counts "
                   "agree species by species once every vector carries its two ghosts "
                   "(IGC.horizon_agrees_iff), so the agreement is not independent evidence "
                   "about the content.",
        evidence="entanglement and contact columns, cited separately from the weight "
                 "formula, evaluated over the same content",
        script="lean/IGC/Horizon.lean",
        lean=["IGC.sm_count", "IGC.horizon_agrees_iff"],
        status="lean",
    ),
    # --- the results ----------------------------------------------------------------
    dict(
        key="species-weight",
        kind="claim",
        text="A species contributes a kinetic part, its statistics sign times its field "
             "components, and a curvature insertion, minus six times its statistics sign "
             "times its curvature trace.",
        original="A species contributes a kinetic part, its statistics sign times its "
                 "degrees of freedom, and a curvature insertion, minus six times its "
                 "curvature trace.",
        correction="'its degrees of freedom' became 'its field components' (a Weyl "
                   "fermion counts 2, a vector 4), and the insertion gained 'its statistics "
                   "sign times': as first worded, every fermion's insertion had the wrong "
                   "sign (a Weyl fermion's is +3, not −3).",
        evidence="the decomposition, per species and summed over a content, and its place "
                 "in the induced coefficient: the kinetic part from the kinetic operator's "
                 "heat-kernel coefficient, the insertion from the inserted curvature term",
        script="lean/IGC/Weights.lean; lean/IGC/OneToSix.lean; lean/IGC/InducedNewton.lean",
        lean=["IGC.Generated.SpeciesRow.weight_eq_kinetic_add_insertion",
              "IGC.netTotal_eq_kinetic_add_insertion", "IGC.one_to_six",
              "IGC.inducesNewton_of_spectralAction"],
        status="lean",
    ),
    dict(
        key="one-to-six",
        kind="claim",
        text="Under K1, the ratio of kinetic part to curvature insertion is one to six "
             "whatever the profile, by an integration-by-parts identity on the profile's "
             "moments.",
        evidence="the kinetic part carries the profile's moment, the insertion taken as "
                 "the first-order response carries its derivative moment, and the "
                 "integration by parts makes the two equal: proved end to end for "
                 "proper-time profiles, and as an identity of moments for every profile of "
                 "bounded variation, the sharp step included",
        script="lean/IGC/OneToSix.lean; lean/IGC/ProperTime.lean; lean/IGC/Profile.lean",
        lean=["IGC.one_to_six", "IGC.ProperTimeProfile.hasDerivAt_F",
              "IGC.ProperTimeProfile.derivativeMoment_eq", "IGC.Profile.derivativeMoment_eq",
              "IGC.Profile.insertionMoment_eq", "IGC.Profile.sharp_f",
              "IGC.Profile.sharp_moment"],
        limited_by=["profile-scope", "sharp-cutoff-in-mean", "constant-insertion"],
        status="lean",
    ),
    dict(
        key="other-operator-loses-ratio",
        kind="claim",
        text="A cutoff taken in another operator transfers a share of that operator's "
             "curvature, and the ratio is lost",
        original="A cutoff taken in another operator transfers a profile-dependent share of "
                 "that operator's curvature, and the ratio is lost",
        correction="'a profile-dependent share' became 'a share', and the sentence is kept "
                   "as K1's motivation, not claimed: a cutoff in another operator is not "
                   "modelled here, and the one model at hand gives a transferred share that "
                   "does not depend on the profile.",
        evidence="not claimed: K1's motivation",
        script="",
        lean=[],
        limited_by=["other-operator"],
        status="limitation",
    ),
    dict(
        key="criterion",
        kind="claim",
        text="The count is positive exactly when the insertion's weighting exceeds "
             "124/21 ≈ 5.905.",
        original="The count is positive exactly when the insertion's weighting exceeds "
                 "5.905.",
        correction="'exceeds 5.905' became 'exceeds 124/21 ≈ 5.905'. The threshold is "
                   "124/21 = 5.90476…; as first worded, the claim was false for weightings "
                   "between 124/21 and 5.905.",
        evidence="the criterion, its threshold for the Standard Model content, and the "
                 "criterion stated for that content",
        script="lean/IGC/Criterion.lean; lean/IGC/StandardModel.lean",
        lean=["IGC.criterion", "IGC.sm_threshold", "IGC.sm_criterion_iff"],
        status="lean",
    ),
    dict(
        key="criterion-margin",
        kind="claim",
        text="K1 gives six, so the margin is 1.59 per cent",
        evidence="the margin against six, the insertion's weighting of six for every "
                 "profile, and the coefficient under K1 at one to six",
        script="lean/IGC/StandardModel.lean; lean/IGC/OneToSix.lean; lean/IGC/Profile.lean",
        lean=["IGC.sm_margin", "IGC.Profile.weighting_eq_six", "IGC.one_to_six"],
        limited_by=["profile-scope", "constant-insertion"],
        status="lean",
    ),
    dict(
        key="profile-family-weighting",
        kind="claim",
        text="the weighting is exactly six for every profile of bounded variation, the "
             "sharp step included",
        original="the weighting is six to within 9 × 10⁻⁶ on every member of the candidate "
                 "profile family",
        correction="the numerical clause, six to within 9 × 10⁻⁶ on a candidate family of "
                   "profiles, became the exact result, which supersedes it: the weighting "
                   "is exactly six for every profile of bounded variation.",
        evidence="the integration by parts between a profile's two moments, by the "
                 "layer-cake formula, for every profile whose derivative is a measure",
        script="lean/IGC/Profile.lean",
        lean=["IGC.Profile.weighting_eq_six", "IGC.Profile.sharp_f",
              "IGC.Profile.sharp_moment"],
        status="lean",
    ),
    dict(
        key="standard-model-count",
        kind="claim",
        text="Kinetic parts −62, curvature insertions +63: net +1.",
        evidence="evaluated exactly over the generated Standard Model content; " + _FIXTURE,
        script="lean/IGC/StandardModel.lean; experiments/run_count.py",
        lean=["IGC.sm_kinetic", "IGC.sm_insertion", "IGC.sm_net"],
        status="lean",
    ),
    dict(
        key="horizon-count",
        kind="claim",
        text="Entanglement entropy 73, less the gauge fields' contact term of 72: net +1, "
             "as the proportionality between horizon entropy and the induced coupling "
             "requires.",
        evidence="evaluated exactly over the same content, and equal to the net under K2; "
                 + _FIXTURE,
        script="lean/IGC/Horizon.lean; experiments/run_count.py",
        lean=["IGC.sm_count", "IGC.horizon_agrees_iff"],
        status="lean",
    ),
    # --- the corollaries -------------------------------------------------------------
    dict(
        key="generation-floor",
        kind="claim",
        text="With the Standard Model's gauge group and one Higgs doublet, the count runs "
             "−44, −29, −14 and +1 for zero to three generations. Gravity attracts only "
             "from three generations on. It is a floor, not a selection.",
        evidence="the count 15g + 4h − 48 for every number of generations g and doublets "
                 "h; with one doublet, −44, −29, −14 and +1 for zero to three, positive "
                 "exactly for g ≥ 3, and the induced Newton constant positive exactly for "
                 "g ≥ 3; results/scan.json, checked by tests/test_scan.py",
        script="lean/IGC/Generations.lean; experiments/run_scan.py",
        lean=["IGC.net_smContent", "IGC.generation_counts", "IGC.generation_floor",
              "IGC.generations_newton"],
        status="lean",
    ),
    dict(
        key="unique-least-content",
        kind="claim",
        text="Among contents of whole generations and Higgs doublets with this gauge group, "
             "the only one whose count is exactly +1 is three generations and one doublet. "
             "With a right-handed neutrino in each generation there is no solution at count "
             "one.",
        original="The only content with this gauge group whose count is exactly +1 is three "
                 "generations and one doublet. With a right-handed neutrino in each "
                 "generation there is no solution at count one.",
        correction="'The only content with this gauge group' became 'Among contents of whole "
                   "generations and Higgs doublets with this gauge group, the only one'. "
                   "With other representations allowed the claim fails: two generations, "
                   "four doublets and three singlet scalars also count +1.",
        evidence="for every g and h, the count is +1 exactly at three generations and one "
                 "doublet, and with a right-handed neutrino per generation it is never +1; "
                 "results/scan.json, checked by tests/test_scan.py",
        script="lean/IGC/Generations.lean; experiments/run_scan.py",
        lean=["IGC.net_smContent", "IGC.unique_count_one", "IGC.no_count_one_with_neutrinos"],
        status="lean",
    ),
    dict(
        key="coupling-bound",
        kind="claim",
        text="Attraction forbids the Higgs doublet's common coupling to curvature at or "
             "above one twenty-fourth, with the gauge fields counted as in K2.",
        original="Attraction forbids a scalar coupling to curvature above one "
                 "twenty-fourth, with the gauge fields counted as in K2.",
        correction="'a scalar coupling' became 'the Higgs doublet's common coupling'. The "
                   "bound 1/24 holds when the doublet's four real scalars share one "
                   "coupling; a single scalar coupled alone would face a different bound. "
                   "And 'above' became 'at or above': the count is exactly zero at "
                   "one twenty-fourth, so the bound is strict (IGC.sm_coupled_newton).",
        evidence="the induced Newton constant of the Standard Model with its four scalars at "
                 "a common coupling, positive exactly below 1/24, over a content that "
                 "satisfies K2",
        script="lean/IGC/Coupling.lean",
        lean=["IGC.sm_coupled_newton", "IGC.sm_coupled_newton_properTime",
              "IGC.sm_higgs_net", "IGC.gaugeFieldsCounted_branch0"],
        status="lean",
    ),
    dict(
        key="neutrino-margins",
        kind="claim",
        text="With two right-handed neutrinos the margin rises to 4.35 per cent, and with "
             "three to 5.56 per cent.",
        evidence="the margins 1/23 and 1/18 against the Standard Model's 1/63, and the "
                 "margin rising with every right-handed neutrino added; " + _FIXTURE,
        script="lean/IGC/Generations.lean; experiments/run_sensitivity.py",
        lean=["IGC.margin_two", "IGC.margin_three", "IGC.sm_margin",
              "IGC.margin_neutrinos_lt"],
        status="lean",
    ),
    dict(
        key="neutrino-sign-robust",
        kind="claim",
        text="The sign is robust to the neutrino content.",
        evidence="net count 1 + n with n right-handed neutrinos, and a positive induced "
                 "Newton constant for every n",
        script="lean/IGC/Generations.lean",
        lean=["IGC.net_neutrinos", "IGC.neutrinos_newton_positive"],
        status="lean",
    ),
    # --- what the paper does not settle ------------------------------------------------
    dict(
        key="magnitude-range",
        kind="claim",
        text="the magnitude of Newton's constant. It depends on the cutoff's scale, and "
             "through it on the cutoff profile's shape, which the paper treats as an input "
             "and reports as a range.",
        evidence="in four dimensions the content induces Newton's constant at the cutoff "
                 "Λ = M_P √(12π/(M·net)), M the profile's normalized moment; over the sharp "
                 "step, the heat kernel and the Gaussian (M = 1, 1, √π/2) the Standard "
                 "Model's Λ runs from 6.14 to 6.52 M_P; results/sensitivity.json, checked "
                 "by tests/test_sensitivity.py and tests/test_closed_forms.py",
        script="lean/IGC/Magnitude.lean; experiments/run_sensitivity.py",
        lean=["IGC.cutoff_for_newton", "IGC.sm_cutoff_for_newton",
              "IGC.normalizedMoment_sharp_four", "IGC.normalizedMoment_heatKernel",
              "IGC.normalizedMoment_gaussian_four"],
        status="lean",
    ),
    # --- what the count forbids, if gravity is induced ---------------------------------
    dict(
        key="gauge-boson-cost",
        kind="claim",
        text="A gauge boson with its two ghosts contributes −4, by either route, and a Weyl "
             "fermion or a minimally coupled real scalar contributes +1, so a content of "
             "these species has count n_scalar + n_Weyl − 4 n_vector.",
        evidence="a vector's induced weight with its two ghosts', and its entanglement "
                 "coefficient with its contact term, each −4; the net count of any content "
                 "of minimally coupled real scalars, Weyl fermions and gauge vectors with "
                 "their ghosts, for every number of each, the Standard Model's contents among "
                 "them",
        script="lean/IGC/Extensions.lean",
        lean=["IGC.gauge_vector_cost", "IGC.net_gaugeContent",
              "IGC.smContent_eq_gaugeContent"],
        citations=["BrodaSzanecki2009", "Kabat1995"],
        status="lean",
    ),
    dict(
        key="extension-rule",
        kind="claim",
        text="If Newton's constant is entirely induced by the species below the cutoff, the "
             "Standard Model extended by b gauge bosons and k further Weyl fermions or "
             "minimally coupled real scalars attracts exactly when k is at least 4b: with "
             "one further gauge boson and nothing else its count is −3, and with a complex "
             "scalar to give that boson its mass, −1.",
        evidence="the extension's net count, the Standard Model's plus k less four per "
                 "boson, and its induced Newton constant, positive exactly when 4b ≤ k, for "
                 "every b and k; the two examples evaluated, and equal to Python's "
                 "(results/scan.json)",
        script="lean/IGC/Extensions.lean; lean/IGC/Agreement.lean; experiments/run_scan.py",
        lean=["IGC.net_smExtension", "IGC.smExtension_pos_iff", "IGC.extension_newton",
              "IGC.sm_plus_one_boson", "IGC.sm_plus_boson_and_scalars",
              "IGC.agree_extensions"],
        limited_by=["induced-premise"],
        status="lean",
    ),
    dict(
        key="conformal-higgs-excluded",
        kind="claim",
        text="If Newton's constant is entirely induced, a conformally coupled Higgs doublet "
             "is excluded: at ξ = 1/6 the Standard Model's count is −3. Higgs inflation is "
             "not excluded, since its coupling has the other sign in this convention and "
             "raises the count.",
        evidence="the Standard Model's count 1 − 24ξ for every real ξ, and no positive "
                 "induced Newton constant at the conformal coupling; the count there, per "
                 "neutrino content, equal to Python's (results/sensitivity.json); Higgs "
                 "inflation's coupling as the input higgs-inflation-coupling states it",
        script="lean/IGC/Extensions.lean; lean/IGC/Coupling.lean; lean/IGC/Agreement.lean",
        lean=["IGC.sm_conformal_net", "IGC.sm_conformal_not_attractive", "IGC.sm_higgs_net",
              "IGC.agree_conformal"],
        citations=["BezrukovShaposhnikov2008"],
        limited_by=["induced-premise"],
        status="lean",
    ),
    # --- what is imported ------------------------------------------------------------
    dict(
        key="heat-kernel-coefficient",
        kind="input",
        text="The heat trace of each species' fluctuation operator, a Laplace-type operator "
             "on a closed manifold: its small-τ expansion through order τ with an O(τ²) "
             "remainder, consumed as the Lean structure IGC.HeatTrace; and its first two "
             "coefficients, a₀ and a₁ = (4π)^(−d/2) ∫ tr(R/6 − E), that is (4π)^(−d/2) "
             "(N/6 − c) ∫√g R for a species of N components whose curvature term has trace "
             "c R, consumed as the Lean structure IGC.Background (Vassilevich, eqs. 2.21 "
             "and 4.26–4.27; for a scalar with curvature coupling ξ, a₁ ∝ 1/6 − ξ, Birrell "
             "and Davies, ch. 6)",
        evidence="",
        script="lean/IGC/SpectralTrace.lean; lean/IGC/InducedNewton.lean",
        lean=[],
        citations=["Vassilevich2003", "BirrellDavies1982"],
        status="imported",
    ),
    dict(
        key="spectral-action-expansion",
        kind="input",
        text="For profiles outside the proper-time class, where it is proved instead: the "
             "cutoff trace Tr f(D/L) carries at order L^s the heat trace's a₁ times the "
             "profile's moment ∫ f(u) u^(s − 1) du divided by Γ(s), consumed as the Lean "
             "predicate IGC.SpectralActionA1. Stated for Laplace-transform profiles by van "
             "Suijlekom (Prop. 9.7) and Eckstein and Iochum (Cor. 3.33), for Schwartz "
             "profiles by Estrada, Gracia-Bondía and Várilly, and in four dimensions by "
             "Chamseddine and Connes (eqs. 2.14–2.15). For the sharp cutoff it holds only "
             "in the Cesàro sense (Estrada, Gracia-Bondía and Várilly, sec. 6), which the "
             "predicate does not express",
        evidence="",
        script="lean/IGC/SpectralTrace.lean",
        lean=[],
        citations=["vanSuijlekom2024", "EcksteinIochum2018", "EstradaGraciaBondiaVarilly1998",
                   "ChamseddineConnes1997"],
        status="imported",
    ),
    dict(
        key="induced-action-convention",
        kind="input",
        text="The sign convention: the regulated Euclidean one-loop action is ½ Σ σ log det "
             "D over species, and its curvature term is −(1/16πG) ∫√g R, so that a "
             "minimally coupled scalar induces a positive 1/G, fixed in the Lean "
             "definitions IGC.oneLoopAction and IGC.InducesNewton (Frolov, Fursaev and "
             "Zelnikov, eqs. 2.10 and 2.19)",
        evidence="",
        script="lean/IGC/InducedNewton.lean",
        lean=[],
        citations=["FrolovFursaevZelnikov1997"],
        status="imported",
    ),
    dict(
        key="species-coefficients",
        kind="input",
        text="Each species' statistics sign, components and curvature trace, and the "
             "weights a minimal scalar, a Weyl fermion and a gauge field with its ghosts "
             "induce, in data/species.yaml and the Lean rows IGC.Generated.minimalScalar, "
             "weylFermion, vector and ghost.",
        evidence="the cross-check of the weight formula against the cited weights",
        script="tests/test_species_table.py",
        lean=[],
        citations=["BirrellDavies1982", "BrodaSzanecki2009", "Kabat1995"],
        status="imported",
    ),
    dict(
        key="standard-model-content",
        kind="input",
        text="The Standard Model's content by its parts: the gauge group's twelve vectors, "
             "each with two ghosts; fifteen Weyl fermions per generation, without a "
             "right-handed neutrino; four real scalars per Higgs doublet; three generations "
             "and one doublet. In data/species.yaml's content block and the generated Lean "
             "definition IGC.Generated.smContent",
        evidence="the Standard Model's totals, four scalars, forty-five Weyl fermions and "
                 "twelve vectors, as Broda and Szanecki count them",
        script="tests/test_count_equivalence.py",
        lean=[],
        citations=["PDG2024", "BrodaSzanecki2009"],
        status="imported",
    ),
    dict(
        key="entanglement-weights",
        kind="input",
        text="Each species' coefficient in the horizon's entanglement entropy, in units of "
             "one minimally coupled real scalar (a minimal scalar 1, a Weyl fermion 1, a "
             "vector 2 for its two physical polarizations, a ghost 0), in "
             "data/species.yaml's entanglement column and the Lean field "
             "IGC.Generated.SpeciesRow.entanglement",
        evidence="",
        script="tests/test_species_table.py",
        lean=[],
        citations=["Kabat1995", "LarsenWilczek1996"],
        status="imported",
    ),
    dict(
        key="contact-term",
        kind="input",
        text="The contact term is what reconciles the induced coupling with horizon "
             "entropy: −6 per gauge field, in scalar units, in data/species.yaml's contact "
             "column and the Lean field IGC.Generated.SpeciesRow.contact",
        evidence="the entanglement and contact columns of data/species.yaml",
        script="tests/test_species_table.py",
        lean=[],
        citations=["Kabat1995"],
        status="imported",
    ),
    dict(
        key="horizon-proportionality",
        kind="input",
        text="the proportionality between horizon entropy and the induced coupling",
        evidence="",
        script="",
        lean=[],
        citations=["LarsenWilczek1996"],
        status="imported",
    ),
    dict(
        key="higgs-inflation-coupling",
        kind="input",
        text="Higgs inflation's curvature coupling, ξ ≈ 49000 √λ in Bezrukov and "
             "Shaposhnikov's convention (their eq. 13), in which the conformal coupling is "
             "minus one sixth (their footnote 1). In this repository's convention, where it "
             "is plus one sixth, the same coupling is negative, so the count 1 − 24ξ rises "
             "with it",
        evidence="",
        script="",
        lean=[],
        citations=["BezrukovShaposhnikov2008"],
        status="cited",
    ),
]
