import 'dart:math' as math;

import 'dart:ui' show Color;

enum MatchSide { home, away }

enum MatchStatus { upcoming, live, finished }

class Team {
  Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
  });

  final String id;
  final String name;
  final String shortName;
  final Color color;

  String get initials {
    final parts = shortName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return shortName.length >= 2
        ? shortName.substring(0, 2).toUpperCase()
        : shortName.toUpperCase();
  }
}

class MatchNode {
  MatchNode({
    required this.id,
    required this.roundIndex,
    required this.slotIndex,
    this.home,
    this.away,
    this.homeScore,
    this.awayScore,
    this.winner,
    this.homeOdds,
    this.awayOdds,
    this.status = MatchStatus.upcoming,
    this.kickoffLabel,
    this.parentId,
    this.childFeederSlots,
  });

  final String id;
  final int roundIndex;
  final int slotIndex;
  Team? home;
  Team? away;
  int? homeScore;
  int? awayScore;
  MatchSide? winner;
  double? homeOdds;
  double? awayOdds;
  MatchStatus status;
  String? kickoffLabel;
  final String? parentId;
  final List<int>? childFeederSlots;
}

class BracketData {
  BracketData({required this.teams, required this.rounds});

  final List<Team> teams;
  final List<List<MatchNode>> rounds;

  int get roundCount => rounds.length;

  MatchNode? byId(String id) {
    for (final round in rounds) {
      for (final m in round) {
        if (m.id == id) return m;
      }
    }
    return null;
  }

  static int roundCountForTeams(int teamCount) {
    return (math.log(teamCount) / math.ln2).round();
  }
}
