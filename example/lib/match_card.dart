import 'package:animated_tournament_basket/animated_tournament_basket.dart';
import 'package:material_ui/material_ui.dart';

const Color kExampleAccentRed = Color(0xFFE30613);
const Color kExampleLiveGreen = Color(0xFF22C55E);

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    required this.colors,
    required this.width,
    required this.onTap,
  });

  final MatchNode match;
  final BracketColors colors;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: width,
              constraints: const BoxConstraints(minHeight: kCardHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
                boxShadow: colors.isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TeamRow(
                    team: match.home,
                    score: match.homeScore,
                    winner: match.winner == MatchSide.home,
                    colors: colors,
                    isLive: match.status == MatchStatus.live,
                  ),
                  const SizedBox(height: 10),
                  _TeamRow(
                    team: match.away,
                    score: match.awayScore,
                    winner: match.winner == MatchSide.away,
                    colors: colors,
                    isLive: match.status == MatchStatus.live,
                  ),
                ],
              ),
            ),
            if (match.homeOdds != null && match.awayOdds != null)
              Positioned(
                right: 6,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    '${match.homeOdds!.toStringAsFixed(2)} · ${match.awayOdds!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 8,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.team,
    required this.score,
    required this.winner,
    required this.colors,
    required this.isLive,
  });

  final Team? team;
  final int? score;
  final bool winner;
  final BracketColors colors;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final name = team?.shortName ?? '—';
    final weight = winner ? FontWeight.w700 : FontWeight.w500;
    final nameColor = winner ? colors.textPrimary : colors.textSecondary;

    return Row(
      children: [
        _TeamBadge(team: team, colors: colors),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: nameColor,
              fontSize: 11,
              fontWeight: weight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isLive && score != null)
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 4),
            decoration: const BoxDecoration(
              color: kExampleLiveGreen,
              shape: BoxShape.circle,
            ),
          ),
        SizedBox(
          width: 24,
          child: Text(
            score?.toString() ?? '·',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: winner ? kExampleAccentRed : colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({required this.team, required this.colors});

  final Team? team;
  final BracketColors colors;

  @override
  Widget build(BuildContext context) {
    if (team == null) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
      );
    }
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: team!.color.withOpacity(0.85),
        shape: BoxShape.circle,
      ),
      child: Text(
        team!.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
