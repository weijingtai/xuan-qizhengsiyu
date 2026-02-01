class AngleUtils {
  /// Checks if a degree value is within a range defined by start and end degrees.
  /// Handles the 360-degree wrap-around.
  ///
  /// [start] The start of the range (inclusive).
  /// [end] The end of the range (inclusive).
  /// [value] The value to check.
  static bool isInDegreeRange(double start, double end, double value) {
    // Normalize geometric angles just in case, though usually input is 0-360
    start = start % 360;
    end = end % 360;
    value = value % 360;

    if (start <= end) {
      return value >= start && value <= end;
    } else {
      // Range crosses the 0/360 boundary (e.g., 350 to 10)
      return value >= start || value <= end;
    }
  }
}
