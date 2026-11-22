/// Animated single-elimination tournament bracket for Flutter.
///
/// Use [BracketStage] with your own [BracketMatchBuilder] for match cells.
/// Supply [BracketData] and drive [focusedRound] with an [AnimationController]
/// (see the example app for tab UI).
library;

export 'src/config.dart';
export 'src/layout/bracket_layout_engine.dart';
export 'src/model/bracket_models.dart';
export 'src/paint/bracket_connector_painter.dart';
export 'src/theme/bracket_colors.dart';
export 'src/widget/bracket_stage.dart';