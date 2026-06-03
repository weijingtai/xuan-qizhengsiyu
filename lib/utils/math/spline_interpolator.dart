import 'dart:math';

/// Monotonic Cubic Spline Interpolation (Fritsch-Carlson algorithm)
/// Ensures that the interpolated values are monotonic if the input data points are monotonic.
class MonotonicCubicSpline {
  final List<double> x;
  final List<double> y;
  late final List<double> m;

  MonotonicCubicSpline(this.x, this.y) {
    if (x.length != y.length || x.length < 2) {
      throw ArgumentError("X and Y must have same length and at least 2 points.");
    }

    int n = x.length;
    List<double> delta = List.filled(n - 1, 0.0);
    for (int i = 0; i < n - 1; i++) {
      double dx = x[i + 1] - x[i];
      if (dx <= 0) {
        throw ArgumentError("X values must be strictly increasing.");
      }
      delta[i] = (y[i + 1] - y[i]) / dx;
    }

    m = List.filled(n, 0.0);
    for (int i = 1; i < n - 1; i++) {
      m[i] = (delta[i - 1] + delta[i]) / 2.0;
    }
    m[0] = delta[0];
    m[n - 1] = delta[n - 2];

    for (int i = 0; i < n - 1; i++) {
      if (delta[i] == 0) {
        m[i] = 0;
        m[i + 1] = 0;
      } else {
        double alpha = m[i] / delta[i];
        double beta = m[i + 1] / delta[i];
        double h = alpha * alpha + beta * beta;
        if (h > 9.0) {
          double tau = 3.0 / sqrt(h);
          m[i] = tau * alpha * delta[i];
          m[i + 1] = tau * beta * delta[i];
        }
      }
    }
  }

  double interpolate(double val) {
    int n = x.length;
    if (val <= x[0]) return y[0];
    if (val >= x[n - 1]) return y[n - 1];

    // Find the interval [x[i], x[i+1]] that contains val
    int i = 0;
    int low = 0;
    int high = n - 2;
    while (low <= high) {
      int mid = (low + high) >> 1;
      if (val >= x[mid] && val <= x[mid + 1]) {
        i = mid;
        break;
      } else if (val < x[mid]) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    double h = x[i + 1] - x[i];
    double t = (val - x[i]) / h;
    return (y[i] * (1 + 2 * t) + m[i] * h * t) * (1 - t) * (1 - t) +
        (y[i + 1] * (3 - 2 * t) + m[i + 1] * h * (t - 1)) * t * t;
  }
}
