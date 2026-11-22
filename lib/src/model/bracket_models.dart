import 'dart:math' as math;

import 'dart:ui' show Color;

/// Which side won a match.
enum MatchSide {
  /// Home slot advanced.
  home,

  /// Away slot advanced.
  away,
}

/// Lifecycle state of a match slot for styling and host UI.
enum MatchStatus {
  /// Not started.
  upcoming,

  /// In progress.
  live,

  /// Complete.
  finished,
}

/// Competitor shown in a match slot.
class Team {
  /// Creates a team row.
  Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
  });

  /// Stable identifier.
  final String id;

  /// Full name for detail screens.
  final String name;

  /// Label used on match cards.
  final String shortName;

  /// Badge / accent color.
  final Color color;

  /// Up to two characters derived from [shortName].
  String get initials {
    if (shortName.isEmpty) return '';
    final parts = shortName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return shortName.length >= 2
        ? shortName.substring(0, 2).toUpperCase()
        : shortName.toUpperCase();
  }
}

/// One bracket slot: participants, scores, and optional metadata for host UI.
class MatchNode {
  /// Creates a node in the elimination tree.
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

  /// Unique id within [BracketData].
  final String id;

  /// Round index, `0` = first bracket column.
  final int roundIndex;

  /// Position top-to-bottom within [roundIndex].
  final int slotIndex;

  /// Home competitor, if known.
  Team? home;

  /// Away competitor, if known.
  Team? away;

  /// Home score when applicable.
  int? homeScore;

  /// Away score when applicable.
  int? awayScore;

  /// Advanced side when the match is decided.
  MatchSide? winner;

  /// Optional host metadata (e.g. example app odds).
  double? homeOdds;

  /// Optional host metadata (e.g. example app odds).
  double? awayOdds;

  /// Current match lifecycle state.
  MatchStatus status;

  /// Optional host label (e.g. kickoff or status text).
  String? kickoffLabel;

  /// Id of the parent match in the next round, if any.
  final String? parentId;

  /// Feeder slot indices in the previous round, if any.
  final List<int>? childFeederSlots;
}

/// Elimination tree: ordered rounds of [MatchNode] lists.
class BracketData {
  /// Builds bracket data from your backend or mock factory.
  BracketData({required this.teams, required this.rounds});

  /// All teams referenced by the tree.
  final List<Team> teams;

  /// `rounds[i]` holds matches for round `i`; count halves each round.
  final List<List<MatchNode>> rounds;

  /// Number of round columns.
  int get roundCount => rounds.length;

  /// Lookup by [MatchNode.id], or `null`.
  MatchNode? byId(String id) {
    for (final round in rounds) {
      for (final m in round) {
        if (m.id == id) return m;
      }
    }
    return null;
  }

  /// Round count for a power-of-two [teamCount] (e.g. `32` → `5`).
  ///
  /// Layout assumes a full binary tree; non-power-of-two counts are not
  /// supported by [BracketLayoutEngine] (no byes).
  static int roundCountForTeams(int teamCount) {
    assert(
      teamCount > 0 && (teamCount & (teamCount - 1)) == 0,
      'teamCount must be a power of 2',
    );
    return (math.log(teamCount) / math.ln2).round();
  }
}
