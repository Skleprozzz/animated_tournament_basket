import 'dart:ui' show lerpDouble;

import 'dart:ui' show Offset;

import '../config.dart';

class BracketLayoutEngine {
  BracketLayoutEngine({
    required this.roundCount,
    required this.firstRoundMatchCount,
    required this.cardWidth,
    required this.columnPitch,
    this.slotHeight = kCardHeight,
  });

  final int roundCount;
  final int firstRoundMatchCount;
  final double cardWidth;
  final double columnPitch;
  final double slotHeight;

  int matchCountInRound(int roundIndex) => firstRoundMatchCount >> roundIndex;

  double _stackTopY(int stageRound, int slotIndex, double gap) =>
      kStageTopPad + slotIndex * (slotHeight + gap);

  double looseTopY(int stageRound, int slotIndex) =>
      _stackTopY(stageRound, slotIndex, kLooseCardGap);

  double compactTopY(int stageRound, int slotIndex) =>
      _stackTopY(stageRound, slotIndex, kCompactCardGap);

  double restingStageY(int stageRound, int viewFocus, int slotIndex) {
    if (stageRound == viewFocus) {
      return stageRound == 0
          ? looseTopY(stageRound, slotIndex)
          : compactTopY(stageRound, slotIndex);
    }
    return compactTopY(stageRound, slotIndex);
  }

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
      final bottom =
          matchTopY(
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

  double columnLeft(int roundIndex) => roundIndex * columnPitch;

  Offset cardAnchorRight(int roundIndex, int slotIndex, double topY) {
    return Offset(columnLeft(roundIndex) + cardWidth, topY + slotHeight / 2);
  }

  Offset cardAnchorLeft(int roundIndex, int slotIndex, double topY) {
    return Offset(columnLeft(roundIndex), topY + slotHeight / 2);
  }

  double gutterXForFeederRound(int feederRound) =>
      columnLeft(feederRound) + cardWidth + (columnPitch - cardWidth) / 2;
}
