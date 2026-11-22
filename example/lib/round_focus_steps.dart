/// Walks from [from] to [to] in steps of 1; skips no indices between them.
///
/// Example: `roundFocusSteps(from: 0, to: 4)` → `1, 2, 3, 4`.
Iterable<int> roundFocusSteps({required int from, required int to}) sync* {
  if (from == to) {
    return;
  }
  var current = from;
  final delta = to > from ? 1 : -1;
  while (current != to) {
    current += delta;
    yield current;
  }
}
