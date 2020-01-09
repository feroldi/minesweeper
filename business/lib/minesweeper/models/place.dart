import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/pos.dart';

/// A square (or place) in the board which has a [pos] (position) and defines
/// the [kind], [state] and number of adjacent mines ([neighbourMinesCount]) of
/// that place.
class Place {
  final Pos pos;
  final PlaceKind kind;
  final PlaceStateType state;
  final int neighbourMinesCount;

  Place(
      {this.pos,
      this.kind = PlaceKind.safe,
      this.state = PlaceStateType.closed,
      this.neighbourMinesCount = 0});

  Place copyWith(
          {Pos pos,
          PlaceKind kind,
          PlaceStateType state,
          int neighbourMinesCount}) =>
      Place(
        pos: pos ?? this.pos,
        kind: kind ?? this.kind,
        state: state ?? this.state,
        neighbourMinesCount: neighbourMinesCount ?? this.neighbourMinesCount,
      );

  factory Place.asMine(Place place) => place.copyWith(kind: PlaceKind.mine);

  factory Place.open(Place place) {
    final isSafe = place.kind == PlaceKind.safe;
    switch (place.state) {
      case PlaceStateType.closed:
        return place.copyWith(
            state: isSafe ? PlaceStateType.opened : PlaceStateType.exploded);
      case PlaceStateType.flagged:
        return place.copyWith(
            state:
                isSafe ? PlaceStateType.opened : PlaceStateType.flagExploded);
      default:
        return place;
    }
  }

  factory Place.toggle(Place place) =>
      place.copyWith(state: _nextPlaceStateType(place.state));
}

PlaceStateType _nextPlaceStateType(PlaceStateType state) {
  switch (state) {
    case PlaceStateType.closed:
      return PlaceStateType.flagged;
    case PlaceStateType.flagged:
      return PlaceStateType.closed;
    default:
      return state;
  }
}

