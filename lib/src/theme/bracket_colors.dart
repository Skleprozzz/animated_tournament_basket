import 'dart:ui' show Color;

/// Semantic colors for the bracket stage, connectors, and host UI chrome.
class BracketColors {
  /// Creates a full bracket color palette.
  const BracketColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.lineMuted,
    required this.connectorWinner,
    required this.tabBar,
    required this.isDark,
  });

  /// Scaffold and stage backdrop.
  final Color background;

  /// Sheets and elevated panels.
  final Color surface;

  /// Match slot surface when using default styling.
  final Color card;

  /// Outlines and dividers.
  final Color border;

  /// Primary labels.
  final Color textPrimary;

  /// Secondary labels.
  final Color textSecondary;

  /// Default connector stroke when not on a winner path.
  final Color lineMuted;

  /// Connector stroke along advancing winner paths.
  final Color connectorWinner;

  /// App bar / tab bar background in the example.
  final Color tabBar;

  /// Whether this palette targets a dark theme.
  final bool isDark;

  /// Dark bracket palette.
  static const BracketColors dark = BracketColors(
    background: Color(0xFF1A1D24),
    surface: Color(0xFF22262E),
    card: Color(0xFF252830),
    border: Color(0xFF3A3F4A),
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFF9CA3AF),
    lineMuted: Color(0xFF3D4450),
    connectorWinner: Color(0xFFE30613),
    tabBar: Color(0xFF1E2229),
    isDark: true,
  );

  /// Light bracket palette.
  static const BracketColors light = BracketColors(
    background: Color(0xFFF4F5F7),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE5E7EB),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF6B7280),
    lineMuted: Color(0xFFD1D5DB),
    connectorWinner: Color(0xFFE30613),
    tabBar: Color(0xFFFFFFFF),
    isDark: false,
  );
}
