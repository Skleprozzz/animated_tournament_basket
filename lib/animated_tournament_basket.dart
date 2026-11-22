/// Animated single-elimination tournament bracket for Flutter.
///
/// Use [BracketStage] with your own [BracketMatchBuilder] for match cells.
/// Supply [BracketData] and drive [focusedRound] with an [AnimationController]
/// (see the example app for tab UI).
library;

export 'src/config.dart';
export 'src/model/bracket_models.dart';
export 'src/theme/bracket_colors.dart';
export 'src/widget/bracket_stage.dart';
