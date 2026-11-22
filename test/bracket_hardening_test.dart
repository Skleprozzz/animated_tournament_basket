import 'package:animated_tournament_basket/animated_tournament_basket.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('roundCountForTeams rejects non power of two', () {
    expect(
      () => BracketData.roundCountForTeams(24),
      throwsA(isA<AssertionError>()),
    );
    expect(BracketData.roundCountForTeams(32), 5);
  });

  testWidgets('empty BracketData does not throw', (tester) async {
    final data = BracketData(teams: [], rounds: []);
    final controller = AnimationController(
      vsync: const _TestVsync(),
      duration: kRoundAnimDuration,
      value: 1,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BracketStage(
          data: data,
          colors: BracketColors.dark,
          focusedRound: 0,
          animFrom: 0,
          animTo: 0,
          roundAnimation: controller,
          onFocusChanged: (_) {},
          matchBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(BracketStage), findsOneWidget);
  });
}

class _TestVsync implements TickerProvider {
  const _TestVsync();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
