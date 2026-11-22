import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../model/bracket_models.dart';
import '../layout/bracket_layout_engine.dart';
import '../theme/bracket_colors.dart';

/// Draws bracket elbows between feeder matches and child slots.
class BracketConnectorPainter extends CustomPainter {
  /// Creates a painter synced with the current layout and transition.
  BracketConnectorPainter({
    required this.data,
    required this.layout,
    required this.fromFocus,
    required this.toFocus,
    required this.t,
    required this.colors,
    required this.round0MatchCount,
    required this.visibleRounds,
    required this.transitioning,
    required this.focusColumn,
    required this.motionT,
  });

  /// Bracket tree.
  final BracketData data;

  /// Layout used for anchors.
  final BracketLayoutEngine layout;

  /// Transition start round index.
  final int fromFocus;

  /// Transition end round index.
  final int toFocus;

  /// Transition progress in `[0, 1]`.
  final double t;

  /// Connector and winner-path colors.
  final BracketColors colors;

  /// Match count in round `0`.
  final int round0MatchCount;

  /// Round indices currently drawn.
  final Set<int> visibleRounds;

  /// Whether [fromFocus] != [toFocus].
  final bool transitioning;

  /// Layout focus column for peek alignment.
  final int focusColumn;

  /// Same as transition `t` for line fade when advancing rounds.
  final double motionT;

  @override
  void paint(Canvas canvas, Size size) {
    for (var r = 0; r < data.roundCount - 1; r++) {
      final feedersVisible = visibleRounds.contains(r);
      final childrenVisible = visibleRounds.contains(r + 1);
      if (!feedersVisible && !childrenVisible) continue;
      if (!feedersVisible) continue;

      for (final child in data.rounds[r + 1]) {
        final childTop = layout.matchTopY(
          fromFocus,
          toFocus,
          focusColumn,
          r + 1,
          child.slotIndex,
          t,
          transitioning: transitioning,
        );
        final childLeft = layout.cardAnchorLeft(
          r + 1,
          child.slotIndex,
          childTop,
        );
        final gutterX = layout.gutterXForFeederRound(r);

        final feederIndices = [child.slotIndex * 2, child.slotIndex * 2 + 1];
        for (var fi = 0; fi < feederIndices.length; fi++) {
          final slot = feederIndices[fi];
          if (slot >= data.rounds[r].length) continue;
          final feeder = data.rounds[r][slot];
          final feederTop = layout.matchTopY(
            fromFocus,
            toFocus,
            focusColumn,
            r,
            slot,
            t,
            transitioning: transitioning,
          );
          final feederRight = layout.cardAnchorRight(r, slot, feederTop);

          final isWinnerPath = _feedsWinner(feeder, child);
          final baseColor = isWinnerPath
              ? colors.connectorWinner
              : colors.lineMuted;
          final goingDeeper = toFocus > fromFocus;
          final fadingOutgoingColumn =
              transitioning && goingDeeper && r == fromFocus;
          final lineFade = fadingOutgoingColumn
              ? (1.0 - motionT).clamp(0.0, 1.0)
              : 1.0;
          final stroke = Paint()
            ..color = baseColor.withOpacity(lineFade)
            ..strokeWidth = isWinnerPath ? 2 : 1.5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;

          _drawElbow(canvas, stroke, feederRight, gutterX, childLeft);
        }
      }
    }
  }

  bool _feedsWinner(MatchNode feeder, MatchNode child) {
    if (feeder.winner == null) return false;
    if (child.home == null && child.away == null) return false;
    final winnerTeam = feeder.winner == MatchSide.home
        ? feeder.home
        : feeder.away;
    if (winnerTeam == null) return false;
    return winnerTeam == child.home || winnerTeam == child.away;
  }

  void _drawElbow(
    Canvas canvas,
    Paint paint,
    Offset start,
    double gutterX,
    Offset end,
  ) {
    const maxR = 6.0;
    final path = Path()..moveTo(start.dx, start.dy);

    final toGutter = gutterX - start.dx;
    final toChild = end.dx - gutterX;
    if (toGutter <= 0 || toChild <= 0) {
      path
        ..lineTo(gutterX, start.dy)
        ..lineTo(gutterX, end.dy)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(path, paint);
      return;
    }

    final down = end.dy >= start.dy;
    final dy = (end.dy - start.dy).abs();
    final r = math
        .min(maxR, math.min(dy * 0.5, math.min(toGutter * 0.5, toChild * 0.5)))
        .clamp(0.0, maxR);

    if (r < 0.75) {
      path
        ..lineTo(gutterX, start.dy)
        ..lineTo(gutterX, end.dy)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(path, paint);
      return;
    }

    final sy = down ? 1.0 : -1.0;

    path.lineTo(gutterX - r, start.dy);
    path.arcToPoint(
      Offset(gutterX, start.dy + sy * r),
      radius: Radius.circular(r),
      clockwise: down,
    );
    path.lineTo(gutterX, end.dy - sy * r);
    path.arcToPoint(
      Offset(gutterX + r, end.dy),
      radius: Radius.circular(r),
      clockwise: !down,
    );
    path.lineTo(end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BracketConnectorPainter old) {
    return old.fromFocus != fromFocus ||
        old.toFocus != toFocus ||
        old.t != t ||
        old.colors != colors ||
        old.visibleRounds != visibleRounds ||
        old.focusColumn != focusColumn ||
        old.motionT != motionT;
  }
}
