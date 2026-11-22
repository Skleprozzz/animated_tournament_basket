import 'package:animated_tournament_basket/animated_tournament_basket.dart';
import 'package:material_ui/material_ui.dart';

import 'match_card.dart';
import 'mock_bracket.dart';
import 'round_tab_bar.dart';

void main() {
  runApp(const TournamentBracketApp());
}

class TournamentBracketApp extends StatefulWidget {
  const TournamentBracketApp({super.key});

  @override
  State<TournamentBracketApp> createState() => _TournamentBracketAppState();
}

class _TournamentBracketAppState extends State<TournamentBracketApp> {
  bool _isDark = true;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    final colors = _isDark ? BracketColors.dark : BracketColors.light;
    return MaterialApp(
      title: 'Tournament Bracket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: colors.background,
        useMaterial3: true,
      ),
      home: TournamentHome(colors: colors, onToggleTheme: _toggleTheme),
    );
  }
}

class TournamentHome extends StatefulWidget {
  const TournamentHome({
    super.key,
    required this.colors,
    required this.onToggleTheme,
  });

  final BracketColors colors;
  final VoidCallback onToggleTheme;

  @override
  State<TournamentHome> createState() => _TournamentHomeState();
}

class _TournamentHomeState extends State<TournamentHome>
    with SingleTickerProviderStateMixin {
  late final BracketData _data = ExampleBracketMock.build(
    teamCount: kExampleBracketTeamCount,
  );
  late int _focusedRound = 0;
  late int _animFrom;
  late int _animTo;
  late final AnimationController _roundController;
  late final CurvedAnimation _roundCurve;

  @override
  void initState() {
    super.initState();
    _animFrom = _focusedRound;
    _animTo = _focusedRound;
    _roundController = AnimationController(
      vsync: this,
      duration: kRoundAnimDuration,
      value: 1,
    );
    _roundCurve = CurvedAnimation(
      parent: _roundController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _roundController.dispose();
    super.dispose();
  }

  void _setFocusedRound(int next) {
    final clamped = next.clamp(0, _data.roundCount - 1);
    if (clamped == _focusedRound) return;
    final from = _focusedRound;
    _roundController.stop();
    _roundController.value = 0;
    setState(() {
      _animFrom = from;
      _animTo = clamped;
      _focusedRound = clamped;
    });
    _roundController.forward().whenComplete(() {
      if (!mounted) return;
      setState(() {
        _animFrom = _focusedRound;
        _animTo = _focusedRound;
      });
    });
  }

  List<String> get _labels => List.generate(
    _data.roundCount,
    (i) => exampleRoundLabel(kExampleBracketTeamCount, i, _data.roundCount),
  );

  void _showMatchSheet(MatchNode match) {
    final c = widget.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${_labels[match.roundIndex]} · Match ${match.slotIndex + 1}',
                style: TextStyle(color: c.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                '${match.home?.name ?? 'TBD'} — ${match.away?.name ?? 'TBD'}',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _statusChip(match, c),
                  const SizedBox(width: 8),
                  if (match.kickoffLabel != null)
                    Text(
                      match.kickoffLabel!,
                      style: TextStyle(color: c.textSecondary, fontSize: 13),
                    ),
                ],
              ),
              if (match.homeScore != null && match.awayScore != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Score: ${match.homeScore} : ${match.awayScore}',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (match.homeOdds != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Odds: ${match.home?.shortName} ${match.homeOdds?.toStringAsFixed(2)} · '
                  '${match.away?.shortName} ${match.awayOdds?.toStringAsFixed(2)}',
                  style: TextStyle(color: c.textSecondary, fontSize: 14),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _statusChip(MatchNode match, BracketColors c) {
    final (label, color) = switch (match.status) {
      MatchStatus.live => ('LIVE', kExampleLiveGreen),
      MatchStatus.finished => ('Final', c.textSecondary),
      MatchStatus.upcoming => ('Soon', kExampleAccentRed),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.tabBar,
        elevation: 0,
        title: Text(
          'Playoffs',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(
              c.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _roundCurve,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RoundTabBar(
                labels: _labels,
                selectedIndex: _focusedRound,
                onSelected: _setFocusedRound,
                colors: c,
                animValue: _roundCurve.value,
                animFrom: _animFrom,
                animTo: _animTo,
              ),
              Expanded(
                child: BracketStage(
                  data: _data,
                  colors: c,
                  focusedRound: _focusedRound,
                  animFrom: _animFrom,
                  animTo: _animTo,
                  roundAnimation: _roundCurve,
                  onFocusChanged: _setFocusedRound,
                  matchBuilder: (context, match, width) => MatchCard(
                    match: match,
                    colors: c,
                    width: width,
                    onTap: () => _showMatchSheet(match),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
