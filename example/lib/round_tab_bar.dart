import 'dart:ui' show lerpDouble;

import 'package:animated_tournament_basket/animated_tournament_basket.dart';
import 'package:material_ui/material_ui.dart';

import 'match_card.dart';

class RoundTabBar extends StatefulWidget {
  const RoundTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    required this.colors,
    required this.animValue,
    required this.animFrom,
    required this.animTo,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final BracketColors colors;
  final double animValue;
  final int animFrom;
  final int animTo;

  @override
  State<RoundTabBar> createState() => _RoundTabBarState();
}

class _RoundTabBarState extends State<RoundTabBar> {
  final _scroll = ScrollController();
  final _keys = <GlobalKey>[];

  @override
  void initState() {
    super.initState();
    _keys.addAll(List.generate(widget.labels.length, (_) => GlobalKey()));
  }

  @override
  void didUpdateWidget(covariant RoundTabBar old) {
    super.didUpdateWidget(old);
    if (old.labels.length != widget.labels.length) {
      _keys
        ..clear()
        ..addAll(List.generate(widget.labels.length, (_) => GlobalKey()));
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  double? _tabLeft(int index) {
    final ctx = _keys[index].currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final parent = context.findRenderObject() as RenderBox?;
    if (parent == null) return null;
    final pos = box.localToGlobal(Offset.zero, ancestor: parent);
    return pos.dx;
  }

  double? _tabWidth(int index) {
    final ctx = _keys[index].currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    return box?.size.width;
  }

  @override
  Widget build(BuildContext context) {
    final visualIndex =
        lerpDouble(
          widget.animFrom.toDouble(),
          widget.animTo.toDouble(),
          widget.animValue,
        ) ??
        widget.selectedIndex.toDouble();
    final leftIdx = visualIndex.floor().clamp(0, widget.labels.length - 1);
    final rightIdx = visualIndex.ceil().clamp(0, widget.labels.length - 1);
    final frac = visualIndex - leftIdx;

    double? indicatorLeft;
    double? indicatorWidth;
    final leftL = _tabLeft(leftIdx);
    final leftW = _tabWidth(leftIdx);
    final rightL = _tabLeft(rightIdx);
    final rightW = _tabWidth(rightIdx);
    if (leftL != null && leftW != null && rightL != null && rightW != null) {
      indicatorLeft = lerpDouble(leftL, rightL, frac);
      indicatorWidth = lerpDouble(leftW, rightW, frac);
    } else {
      const tabWidth = 72.0;
      const start = 12.0;
      indicatorLeft = lerpDouble(
        start + leftIdx * tabWidth,
        start + rightIdx * tabWidth,
        frac,
      );
      indicatorWidth = tabWidth;
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: widget.colors.tabBar,
        border: Border(bottom: BorderSide(color: widget.colors.border)),
      ),
      child: Stack(
        children: [
          if (indicatorLeft != null && indicatorWidth != null)
            Positioned(
              left: indicatorLeft,
              bottom: 0,
              width: indicatorWidth,
              height: 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: kExampleAccentRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (var i = 0; i < widget.labels.length; i++)
                  SizedBox(
                    width: 72,
                    child: TextButton(
                      key: _keys[i],
                      onPressed: () => widget.onSelected(i),
                      style: TextButton.styleFrom(
                        foregroundColor: i == widget.selectedIndex
                            ? widget.colors.textPrimary
                            : widget.colors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        widget.labels[i],
                        style: TextStyle(
                          fontWeight: i == widget.selectedIndex
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
