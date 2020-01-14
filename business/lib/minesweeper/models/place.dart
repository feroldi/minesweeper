import 'package:flutter/foundation.dart' show describeEnum;
import 'package:quiver/core.dart' show hash2;

import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/pos.dart';

/// A square (or place) in the board.
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
    if (place.state == PlaceStateType.closed) {
      return place.copyWith(
          state: isSafe ? PlaceStateType.opened : PlaceStateType.exploded);
    } else if (place.state == PlaceStateType.flagged && isSafe) {
      return place.copyWith(state: PlaceStateType.wronglyFlagged);
    } else {
      return place;
    }
  }

  factory Place.toggle(Place place) =>
      place.copyWith(state: _nextPlaceStateType(place.state));

  Map<String, dynamic> toJson() => <String, dynamic>{
        "kind": describeEnum(kind),
        "state": describeEnum(state),
      };

  bool operator ==(Object o) =>
      o is Place &&
      o.runtimeType == this.runtimeType &&
      o.pos == pos &&
      o.kind == kind &&
      o.state == state;

  int get hashCode => hash2(hash2(pos, kind), state);
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
