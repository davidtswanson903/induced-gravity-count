"""Closed forms, checked against the full computation, with their conditions.

For each standard profile, at s = 1 (four dimensions) and s = 2 (six), the profile's
moment, int_0^oo f(u) u^(s-1) du, and its derivative moment, -int u^s df, are computed by
quadrature and checked against:
  - the closed-form normalized moment igc.sensitivity uses (lean/IGC/Magnitude.lean);
  - the integration by parts, derivative moment = s * moment (lean/IGC/Profile.lean),
    so that the insertion's weighting is exactly six.
The sharp step's derivative is minus the unit mass at 1, so its derivative moment is
1^s = 1 exactly; only its moment is integrated.

Quadrature is the one numerical step in the repository, so its tolerance is the one
validated in a second, independently resolved environment:
    uv run --isolated --with mpmath==1.2.1 --with pytest --with pyyaml \
        pytest tests/test_closed_forms.py
passes at the same tolerance as the project environment's mpmath.
"""
import pytest

mpmath = pytest.importorskip("mpmath")

from igc import sensitivity  # noqa: E402

TOL = mpmath.mpf("1e-20")
mpmath.mp.dps = 40


def _profiles():
    exp, inf = mpmath.exp, mpmath.inf
    return {
        "heat_kernel": (lambda u: exp(-u), lambda u: -exp(-u), [0, inf]),
        "gaussian": (lambda u: exp(-u ** 2), lambda u: -2 * u * exp(-u ** 2), [0, inf]),
    }


@pytest.mark.parametrize("s", [1, 2])
@pytest.mark.parametrize("profile", ["heat_kernel", "gaussian"])
def test_smooth_profile(profile, s):
    f, df, span = _profiles()[profile]
    moment = mpmath.quad(lambda u: f(u) * u ** (s - 1), span)
    derivative_moment = -mpmath.quad(lambda u: df(u) * u ** s, span)
    closed = sensitivity.normalized_moment(profile, float(s)) * mpmath.gamma(s)
    assert abs(moment - mpmath.mpf(closed)) <= mpmath.mpf("1e-14")  # closed form is a float
    assert abs(derivative_moment - s * moment) <= TOL
    assert abs(6 * (derivative_moment / s) / moment - 6) <= TOL


@pytest.mark.parametrize("s", [1, 2])
def test_sharp_step(s):
    moment = mpmath.quad(lambda u: u ** (s - 1), [0, 1])
    derivative_moment = mpmath.mpf(1) ** s
    closed = sensitivity.normalized_moment("sharp_step", float(s)) * mpmath.gamma(s)
    assert abs(moment - mpmath.mpf(closed)) <= mpmath.mpf("1e-14")
    assert abs(derivative_moment - s * moment) <= TOL
