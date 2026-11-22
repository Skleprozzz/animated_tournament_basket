import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import '../config.dart';
import '../layout/bracket_layout_engine.dart';
import '../model/bracket_models.dart';
import '../paint/bracket_connector_painter.dart';
import '../theme/bracket_colors.dart';

typedef BracketMatchBuilder =
    Widget Function(BuildContext context, MatchNode match, double width);

class BracketStage extends StatefulWidget {
  const BracketStage({
    super.key,
    required this.data,
    required this.colors,
    required this.focusedRound,
    required this.animFrom,
    required this.animTo,
    required this.roundAnimation,
    required this.onFocusChanged,
    required this.matchBuilder,
    this.slotHeight = kCardHeight,
  });

  final BracketData data;
  final BracketColors colors;
  final int focusedRound;
  final int animFrom;
  final int animTo;
  final Animation<double> roundAnimation;
  final ValueChanged<int> onFocusChanged;
  final BracketMatchBuilder matchBuilder;
  final double slotHeight;

  @override
  State<BracketStage> createState() => _BracketStageState();
}

class _BracketStageState extends State<BracketStage> {
  double _dragAccum = 0;

  BracketLayoutEngine _layoutFor(double cardWidth, double columnPitch) =>
      BracketLayoutEngine(
        roundCount: widget.data.roundCount,
        firstRoundMatchCount: widget.data.rounds.first.length,
        cardWidth: cardWidth,
        columnPitch: columnPitch,
        slotHeight: widget.slotHeight,
      );

  void _goDelta(int delta) {
    final next = (widget.focusedRound + delta).clamp(
      0,
      widget.data.roundCount - 1,
    );
    if (next != widget.focusedRound) {
      widget.onFocusChanged(next);
    }
  }

  double get _t => widget.roundAnimation.value;

  bool get _phaseActive => widget.animFrom != widget.animTo;

  double get _horizontalRound {
    if (!_phaseActive) return widget.focusedRound.toDouble();
    return lerpDouble(
      widget.animFrom.toDouble(),
      widget.animTo.toDouble(),
      _t,
    )!;
  }

  int get _layoutFocus {
    if (!_phaseActive) return widget.focusedRound;
    return _t < 0.5 ? widget.animFrom : widget.animTo;
  }

  Set<int> _visibleCardRounds(int focus) {
    final last = widget.data.roundCount - 1;
    if (_phaseActive) {
      final rounds = {widget.animFrom, widget.animTo};
      final goingDeeper = widget.animTo > widget.animFrom;
      if (goingDeeper) {
        if (_t >= 0.5 && widget.animTo < last) {
          rounds.add(widget.animTo + 1);
        } else if (widget.animFrom < last) {
          rounds.add(widget.animFrom + 1);
        }
      } else {
        if (_t < 0.5 && widget.animFrom < last) {
          rounds.add(widget.animFrom + 1);
        } else if (widget.animTo < last) {
          rounds.add(widget.animTo + 1);
        }
      }
      return rounds;
    }
    final rounds = <int>{focus};
    if (focus < last) rounds.add(focus + 1);
    return rounds;
  }

  double _viewportHeight(
    BracketLayoutEngine layout,
    int layoutFocus,
    Set<int> columns,
    double t, {
    required bool inPhase,
  }) {
    var height = 0.0;
    for (final col in columns) {
      height = math.max(
        height,
        layout.contentHeightForColumn(
          col,
          widget.animFrom,
          widget.animTo,
          layoutFocus,
          t,
          transitioning: inPhase,
        ),
      );
    }
    return height;
  }

  double _animatedViewportHeight(
    BracketLayoutEngine layout,
    int layoutFocus,
    Set<int> columns,
  ) {
    return _viewportHeight(
      layout,
      layoutFocus,
      columns,
      _phaseActive ? _t : 1,
      inPhase: _phaseActive,
    );
  }

  bool _isRoundVisible(int roundIndex, Set<int> visible) =>
      visible.contains(roundIndex);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport =
            constraints.hasBoundedWidth && constraints.hasBoundedHeight
            ? constraints
            : BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width,
                maxHeight: MediaQuery.sizeOf(context).height,
              );

        return AnimatedBuilder(
          animation: widget.roundAnimation,
          builder: (context, _) {
            final round0Count = widget.data.rounds.first.length;
            final layoutFocus = _layoutFocus;
            final cardRounds = _visibleCardRounds(layoutFocus);

            final viewW = viewport.maxWidth;
            if (viewW <= 0) {
              return const SizedBox.shrink();
            }
            final cardW = math.max(
              120.0,
              viewW - kViewportPadH - kNextRoundPeek - kViewportPadH,
            );
            final columnPitch = viewW - kNextRoundPeek;
            final layout = _layoutFor(cardW, columnPitch);
            final height = _animatedViewportHeight(
              layout,
              layoutFocus,
              cardRounds,
            );
            final slideX = kViewportPadH - _horizontalRound * columnPitch;
            final totalWidth = widget.data.roundCount * columnPitch + cardW;
            final connectorRounds = cardRounds;
            final viewH = viewport.maxHeight.isFinite
                ? viewport.maxHeight
                : height.clamp(320.0, 1200.0);

            final bracketLayer = Transform.translate(
              offset: Offset(slideX, 0),
              child: SizedBox(
                width: totalWidth,
                height: height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: Size(totalWidth, height),
                      painter: BracketConnectorPainter(
                        data: widget.data,
                        layout: layout,
                        fromFocus: widget.animFrom,
                        toFocus: widget.animTo,
                        t: _t,
                        colors: widget.colors,
                        round0MatchCount: round0Count,
                        visibleRounds: connectorRounds,
                        transitioning: _phaseActive,
                        focusColumn: layoutFocus,
                        motionT: _t,
                      ),
                    ),
                    for (var r = 0; r < widget.data.roundCount; r++)
                      if (_isRoundVisible(r, cardRounds))
                        for (final match in widget.data.rounds[r])
                          _buildSlot(layout, match, cardW, layoutFocus),
                  ],
                ),
              ),
            );

            return GestureDetector(
              onHorizontalDragUpdate: (d) => _dragAccum += d.delta.dx,
              onHorizontalDragEnd: (d) {
                const threshold = 48.0;
                final v = d.primaryVelocity ?? 0;
                if (_dragAccum < -threshold || v < -300) {
                  _goDelta(1);
                } else if (_dragAccum > threshold || v > 300) {
                  _goDelta(-1);
                }
                _dragAccum = 0;
              },
              child: SizedBox(
                width: viewW,
                height: viewH,
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    SizedBox(
                      height: height,
                      width: viewW,
                      child: ClipRect(child: bracketLayer),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSlot(
    BracketLayoutEngine layout,
    MatchNode match,
    double cardWidth,
    int focusColumn,
  ) {
    final topY = layout.matchTopY(
      widget.animFrom,
      widget.animTo,
      focusColumn,
      match.roundIndex,
      match.slotIndex,
      _t,
      transitioning: _phaseActive,
    );
    final left = layout.columnLeft(match.roundIndex);

    Widget slot = widget.matchBuilder(context, match, cardWidth);
    final goingDeeper = _phaseActive && widget.animTo > widget.animFrom;
    if (goingDeeper && match.roundIndex == widget.animFrom) {
      slot = Opacity(opacity: (1.0 - _t).clamp(0.0, 1.0), child: slot);
    }

    return Positioned(left: left, top: topY, child: slot);
  }
}
