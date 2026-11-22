# animated_tournament_basket

Animated single-elimination tournament bracket for Flutter: horizontal round carousel, vertical stack animation, and `CustomPainter` connector paths. Match cells are **your widgets** via `BracketStage.matchBuilder`.

## Demo

![Bracket tabs and round animation](example/demo_gifs/bracket_demo.gif)

Run the example for the full recording: `cd example && flutter run`.  
[Demo video (MP4)](example/demo_gifs/bracket_demo.mp4)

## Install

```yaml
dependencies:
  animated_tournament_basket: ^0.1.3
```

## Minimal usage

```dart
import 'package:animated_tournament_basket/animated_tournament_basket.dart';

BracketStage(
  data: bracketData,
  colors: BracketColors.dark,
  focusedRound: round,
  animFrom: animFrom,
  animTo: animTo,
  roundAnimation: roundAnimation,
  onFocusChanged: (i) => setState(() => round = i),
  matchBuilder: (context, match, width) => MyMatchTile(match: match, width: width),
);
```

Provide `BracketData` (teams + `List<List<MatchNode>> rounds`). Layout constants such as `kCardHeight` and `kRoundAnimDuration` are exported from the package.

## Example

```bash
cd example
flutter run
```

The example includes round tabs, theme toggle, demo match cards, and mock US/EU team data — not part of the library API.

## Layout and animation

See [doc/BRACKET_LAYOUT_AND_ANIMATION.md](doc/BRACKET_LAYOUT_AND_ANIMATION.md).

## Publishing (maintainers)

```bash
dart pub publish
```

Dry run: `dart pub publish --dry-run`.

## License

MIT — see [LICENSE](LICENSE).