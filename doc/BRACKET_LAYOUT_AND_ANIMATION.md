# Playoff bracket: layout and animation

**Package:** `lib/` — `BracketStage`, `BracketLayoutEngine`, `BracketConnectorPainter`, models, `BracketColors`.

**Example (not part of the package API):** `example/lib/` — `TournamentHome`, `RoundTabBar`, `MatchCard`, `ExampleBracketMock`.

---

## Purpose

Animated tournament bracket: **one full-width match column + peek of the next round**, horizontal slide between rounds, vertical collapse/expand of stacks, `CustomPainter` connectors, customizable match slot widgets.

Not a full binary-tree layout on screen — only **2–3 round columns** are positioned and drawn at once. Round tabs and demo cards live in the example app only.

---

## Architecture overview

| Layer | Location | Responsibility |
|--------|----------|----------------|
| `TournamentHome` | `example/lib/main.dart` | `AnimationController`, theme, tabs, `focusedRound` / `animFrom` / `animTo` |
| `RoundTabBar` | `example/lib/round_tab_bar.dart` | Tab labels, indicator interpolated with animation `t` |
| `BracketStage` | `lib/src/widget/bracket_stage.dart` | Viewport, slide transform, slot `Stack`, swipe between rounds |
| `BracketLayoutEngine` | `lib/src/layout/bracket_layout_engine.dart` | Card **X/Y** and connector anchor geometry |
| `BracketConnectorPainter` | `lib/src/paint/bracket_connector_painter.dart` | Connector elbows; colors from `BracketColors` |
| `BracketData` / `MatchNode` | `lib/src/model/bracket_models.dart` | Bracket tree supplied by the host app |

One animation driver in the host: `roundAnimation` (`CurvedAnimation`, `kRoundAnimDuration`, default 2s). Scalar **`t` ∈ [0, 1]** drives horizontal slide, vertical lerp, viewport height, and (forward-only) fade.

---

## Key constants (`lib/src/config.dart`)

| Constant | Role |
|----------|------|
| `kCardHeight` (96) | Default slot height (`BracketStage.slotHeight`) |
| `kLooseCardGap` (14) | Vertical gap for **round 0** main column |
| `kCompactCardGap` (8) | Vertical gap for other main columns |
| `kViewportPadH` (16) | Horizontal padding in viewport |
| `kNextRoundPeek` (56) | Visible width of next-round column on the right |

---

## Horizontal layout (column carousel)

**Files:** `bracket_stage.dart`, `bracket_layout_engine.dart`.

- **`columnPitch`** = viewport width − `kNextRoundPeek`.
- **`cardW`** = viewport − padding − peek − padding (min 120).
- Column `r` left edge: `r * columnPitch` (`columnLeft`).
- Visible window: bracket layer translated by `slideX = kViewportPadH - _horizontalRound * columnPitch`.
- **`_horizontalRound`**: at rest `focusedRound`; during transition `lerp(animFrom, animTo, t)`.

---

## Vertical layout (per-screen columns, not full tree)

See `BracketLayoutEngine.matchTopY` and related methods (same rules as prior single-file implementation).

Match slots are built with `BracketStage.matchBuilder`; connector anchors use `slotHeight`.

---

## Tab change: animation state machine

Implemented in **`example/lib/main.dart`** (`_setFocusedRound`), not in the package.

1. Tab/skip targets update `_targetRound`; each hop advances one index (`round_focus_steps.dart`).
2. Multi-hop chains split `kRoundAnimDuration` evenly across the hop count (fixed when the chain starts).
3. Single ±1 moves (swipe or adjacent tab) use the full `kRoundAnimDuration`.

**`_phaseActive`** = `animFrom != animTo`.

---

## Connectors (`BracketConnectorPainter`)

Winner feeder paths use `BracketColors.connectorWinner`; other lines use `lineMuted`. Forward transition fades outgoing feeder column with `(1 - motionT)`.

---

## Data model

- Rounds: `List<List<MatchNode>>`, counts halve each round.
- Example labels: `exampleRoundLabel` in `example/lib/mock_bracket.dart` (`1/16` … `Final`).
- Mock data: `ExampleBracketMock.build()` in the example only.

---

## Commands

```text
cd animated_tournament_basket
dart format lib
flutter analyze

cd example
flutter run
```

---

## Document meta

Handoff spec for layout/animation behavior in the `animated_tournament_basket` package sources under `lib/src/`.