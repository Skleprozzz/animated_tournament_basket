import 'dart:math' as math;

import 'package:animated_tournament_basket/animated_tournament_basket.dart';
import 'dart:ui' show Color;

const int kExampleBracketTeamCount = 32;

String exampleRoundLabel(int teamCount, int roundIndex, int roundCount) {
  if (roundIndex == roundCount - 1) return 'Final';
  final matchesInRound = teamCount ~/ (1 << (roundIndex + 1));
  final denominator = matchesInRound * 2;
  return '1/$denominator';
}

class ExampleBracketMock {
  static BracketData build({int teamCount = kExampleBracketTeamCount}) {
    assert(_isPowerOfTwo(teamCount), 'teamCount must be power of 2');

    final palette = [
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFFEF4444),
      const Color(0xFF84CC16),
    ];

    const names = [
      'Lakers',
      'Celtics',
      'Warriors',
      'Bucks',
      'Nuggets',
      'Heat',
      'Suns',
      'Mavs',
      'Knicks',
      'Sixers',
      'Cavaliers',
      'Clippers',
      'Kings',
      'Timberwolves',
      'Thunder',
      'Pelicans',
      'Arsenal',
      'Liverpool',
      'Man City',
      'Chelsea',
      'Barcelona',
      'Real Madrid',
      'Bayern',
      'Dortmund',
      'Inter',
      'Juventus',
      'Milan',
      'Napoli',
      'PSG',
      'Lyon',
      'Ajax',
      'Benfica',
    ];

    final teams = <Team>[];
    for (var i = 0; i < teamCount; i++) {
      final name = names[i % names.length];
      teams.add(
        Team(
          id: 't$i',
          name: name,
          shortName: name,
          color: palette[i % palette.length],
        ),
      );
    }

    final rc = BracketData.roundCountForTeams(teamCount);
    final rounds = <List<MatchNode>>[];
    final rng = math.Random(42);

    for (var r = 0; r < rc; r++) {
      final matchCount = teamCount ~/ (1 << (r + 1));
      final round = <MatchNode>[];
      for (var m = 0; m < matchCount; m++) {
        final id = 'r${r}_m$m';
        round.add(
          MatchNode(
            id: id,
            roundIndex: r,
            slotIndex: m,
            parentId: r < rc - 1 ? 'r${r + 1}_m${m >> 1}' : null,
            childFeederSlots: r > 0 ? [m << 1, (m << 1) + 1] : null,
          ),
        );
      }
      rounds.add(round);
    }

    final first = rounds[0];
    for (var i = 0; i < first.length; i++) {
      final match = first[i];
      match.home = teams[i * 2];
      match.away = teams[i * 2 + 1];
      match.homeOdds = 1.55 + rng.nextDouble() * 1.2;
      match.awayOdds = 1.55 + rng.nextDouble() * 1.2;
      if (i < first.length - 2) {
        match.status = MatchStatus.finished;
        match.homeScore = 65 + rng.nextInt(45);
        match.awayScore = 62 + rng.nextInt(45);
        if (match.homeScore == match.awayScore) {
          match.homeScore = match.homeScore! + 1;
        }
        match.winner = match.homeScore! > match.awayScore!
            ? MatchSide.home
            : MatchSide.away;
        match.kickoffLabel = 'Final';
      } else if (i == first.length - 2) {
        match.status = MatchStatus.live;
        match.homeScore = 58;
        match.awayScore = 54;
        match.kickoffLabel = 'Q4 03:12';
      } else {
        match.status = MatchStatus.upcoming;
        match.kickoffLabel = 'Tomorrow 8:00 PM';
      }
    }

    for (var r = 0; r < rc - 1; r++) {
      for (final match in rounds[r]) {
        if (match.winner == null) continue;
        final parent = rounds[r + 1][match.slotIndex >> 1];
        final winnerTeam = match.winner == MatchSide.home
            ? match.home
            : match.away;
        if (match.slotIndex.isEven) {
          parent.home = winnerTeam;
        } else {
          parent.away = winnerTeam;
        }
      }
      if (r == 0) continue;
      for (final match in rounds[r]) {
        if (match.home != null && match.away != null) {
          if (r < rc - 2) {
            match.status = MatchStatus.finished;
            match.homeScore = 70 + rng.nextInt(40);
            match.awayScore = 68 + rng.nextInt(40);
            if (match.homeScore == match.awayScore) {
              match.homeScore = match.homeScore! + 1;
            }
            match.winner = match.homeScore! > match.awayScore!
                ? MatchSide.home
                : MatchSide.away;
            match.kickoffLabel = 'Final';
          } else if (r == rc - 2) {
            match.status = MatchStatus.upcoming;
            match.homeOdds = 1.72;
            match.awayOdds = 2.05;
            match.kickoffLabel = 'Sat 7:30 PM';
          }
        }
      }
    }

    final finalMatch = rounds[rc - 1].first;
    if (finalMatch.home != null || finalMatch.away != null) {
      finalMatch.status = MatchStatus.upcoming;
      finalMatch.homeOdds = 1.90;
      finalMatch.awayOdds = 1.95;
      finalMatch.kickoffLabel = 'Final · Sun 6:00 PM';
    }

    return BracketData(teams: teams, rounds: rounds);
  }

  static bool _isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;
}
