import 'dart:ui' show Offset, lerpDouble;

import '../config.dart';

/// Computes match slot positions and connector anchor points for [BracketStage].
class BracketLayoutEngine {
  /// Creates a layout for the given viewport geometry.
  BracketLayoutEngine({
    required this.roundCount,
    required this.firstRoundMatchCount,
    required this.cardWidth,
    required this.columnPitch,
    this.slotHeight = kCardHeight,
  });

  /// Total round columns in the tree.
  final int roundCount;

  /// Matches in round `0`.
  final int firstRoundMatchCount;

  /// Width of each match slot.
  final double cardWidth;

  /// Horizontal distance between round column origins.
  final double columnPitch;

  /// Vertical size of each slot used for stacking and connectors.
  final double slotHeight;

  /// Matches in [roundIndex] (`firstRoundMatchCount >> roundIndex`).
  int matchCountInRound(int roundIndex) => firstRoundMatchCount >> roundIndex;

  double _stackTopY(int stageRound, int slotIndex, double gap) =>
      kStageTopPad + slotIndex * (slotHeight + gap);

  /// Top Y for round `0` slots using [kLooseCardGap].
  double looseTopY(int stageRound, int slotIndex) =>
      _stackTopY(stageRound, slotIndex, kLooseCardGap);

  /// Top Y using [kCompactCardGap].
  double compactTopY(int stageRound, int slotIndex) =>
      _stackTopY(stageRound, slotIndex, kCompactCardGap);

  /// Resting Y for a slot when [viewFocus] is the active tab.
  double restingStageY(int stageRound, int viewFocus, int slotIndex) {
    if (stageRound == viewFocus) {
      return stageRound == 0
          ? looseTopY(stageRound, slotIndex)
          : compactTopY(stageRound, slotIndex);
    }
    return compactTopY(stageRound, slotIndex);
  }

  /// Column layout Y for one tab snapshot (main column + peek alignment).
  double layoutStageYForView(
    int stageRound,
    int viewFocus,
    int slotIndex,
    int animFrom,
    int animTo,
  ) {
    if (stageRound == viewFocus + 1) {
      return _childAlignedTopY(
        viewFocus,
        slotIndex,
        viewFocus,
        viewFocus,
        viewFocus,
        1,
        transitioning: false,
      );
    }
    if (stageRound == viewFocus) {
      return restingStageY(stageRound, viewFocus, slotIndex);
    }
    return compactTopY(stageRound, slotIndex);
  }

  double _childAlignedTopY(
    int parentRound,
    int childSlot,
    int animFrom,
    int animTo,
    int focusColumn,
    double t, {
    required bool transitioning,
  }) {
    final i0 = childSlot << 1;
    final i1 = i0 + 1;
    final n = matchCountInRound(parentRound);
    final top0 = matchTopY(
      animFrom,
      animTo,
      focusColumn,
      parentRound,
      i0.clamp(0, n - 1),
      t,
      transitioning: transitioning,
    );
    if (i1 >= n) return top0;
    final top1 = matchTopY(
      animFrom,
      animTo,
      focusColumn,
      parentRound,
      i1,
      t,
      transitioning: transitioning,
    );
    final center = (top0 + top1 + slotHeight) / 2;
    return center - slotHeight / 2;
  }

  double _lerpStageColumnY(
    int animFrom,
    int animTo,
    int stageRound,
    int slotIndex,
    double t, {
    required bool transitioning,
  }) {
    if (!transitioning || animFrom == animTo) {
      return layoutStageYForView(
        stageRound,
        animFrom,
        slotIndex,
        animFrom,
        animTo,
      );
    }

    if (stageRound == animFrom || stageRound == animTo) {
      return lerpDouble(
        layoutStageYForView(stageRound, animFrom, slotIndex, animFrom, animTo),
        layoutStageYForView(stageRound, animTo, slotIndex, animFrom, animTo),
        t,
      )!;
    }
    return compactTopY(stageRound, slotIndex);
  }

  /// Animated top Y for a slot; used by [BracketStage] and connectors.
  double matchTopY(
    int animFrom,
    int animTo,
    int focusColumn,
    int roundIndex,
    int slotIndex,
    double t, {
    required bool transitioning,
  }) {
    if (transitioning &&
        animFrom != animTo &&
        (roundIndex == animFrom || roundIndex == animTo)) {
      return _lerpStageColumnY(
        animFrom,
        animTo,
        roundIndex,
        slotIndex,
        t,
        transitioning: transitioning,
      );
    }
    if (roundIndex == focusColumn + 1) {
      return _childAlignedTopY(
        focusColumn,
        slotIndex,
        animFrom,
        animTo,
        focusColumn,
        t,
        transitioning: transitioning,
      );
    }
    if (roundIndex == focusColumn ||
        roundIndex == animFrom ||
        roundIndex == animTo) {
      return _lerpStageColumnY(
        animFrom,
        animTo,
        roundIndex,
        slotIndex,
        t,
        transitioning: transitioning,
      );
    }
    return compactTopY(roundIndex, slotIndex);
  }

  /// Scrollable height needed for one visible round column.
  double contentHeightForColumn(
    int columnRound,
    int animFrom,
    int animTo,
    int focusColumn,
    double t, {
    required bool transitioning,
  }) {
    final matches = matchCountInRound(columnRound);
    var maxBottom = kStageTopPad;
    for (var s = 0; s < matches; s++) {
      final bottom = matchTopY(
            animFrom,
            animTo,
            focusColumn,
            columnRound,
            s,
            t,
            transitioning: transitioning,
          ) +
          slotHeight;
      if (bottom > maxBottom) maxBottom = bottom;
    }
    return maxBottom + 24;
  }

  /// Left edge X of a round column.
  double columnLeft(int roundIndex) => roundIndex * columnPitch;

  /// Connector start on the right edge of a slot.
  Offset cardAnchorRight(int roundIndex, int slotIndex, double topY) {
    return Offset(columnLeft(roundIndex) + cardWidth, topY + slotHeight / 2);
  }

  /// Connector end on the left edge of a slot.
  Offset cardAnchorLeft(int roundIndex, int slotIndex, double topY) {
    return Offset(columnLeft(roundIndex), topY + slotHeight / 2);
  }

  /// Horizontal gutter X between feeder round and its children.
  double gutterXForFeederRound(int feederRound) =>
      columnLeft(feederRound) + cardWidth + (columnPitch - cardWidth) / 2;
}
