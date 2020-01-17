import 'package:flutter/foundation.dart' show describeEnum;
import 'package:quiver/core.dart' show hash2;

import 'package:business/board/models/place_kind.dart';
import 'package:business/board/models/place_state_type.dart';
import 'package:business/board/models/pos.dart';

/// A square (place) in the board.
///
/// Places make up a game board. A place contains a [pos] to tell where it is
/// located in the board. Its [kind] tells wheter it is safe to reveal, and
/// [state] dictates if this place has or hasn't been releaved, whether it has
/// been flagged, has triggered an explosion and so on. Finally, the
/// [neighbourMinesCount] represents the number of adjacent mines to this
/// place, excluding this place itself (i.e., it does not count if this place
/// is a mine too).
class Place {
  final Pos pos;
  final PlaceKind kind;
  final PlaceStateType state;
  final int neighbourMinesCount;

  Place({
    this.pos,
    this.kind = PlaceKind.safe,
    this.state = PlaceStateType.closed,
    this.neighbourMinesCount = 0,
  });

  Place copyWith({
    Pos pos,
    PlaceKind kind,
    PlaceStateType state,
    int neighbourMinesCount,
  }) =>
      Place(
        pos: pos ?? this.pos,
        kind: kind ?? this.kind,
        state: state ?? this.state,
        neighbourMinesCount: neighbourMinesCount ?? this.neighbourMinesCount,
      );

  /// Swaps a place to be a mine keeping its other attributes.
  factory Place.asMine(Place place) => place.copyWith(kind: PlaceKind.mine);

  /// Reveals a place.
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

  /// Toggles a place, flagging or unflagging it.
  factory Place.toggle(Place place) =>
      place.copyWith(state: _nextPlaceStateType(place.state));

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        pos: Pos.fromJson(json["pos"].cast<String, int>()),
        kind: _stringToPlaceKind(json["kind"]),
        state: _stringToPlaceStateType(json["state"]),
        neighbourMinesCount: json["neighbourMinesCount"],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "pos": pos.toJson(),
        "kind": describeEnum(kind),
        "state": describeEnum(state),
        "neighbourMinesCount": neighbourMinesCount,
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

PlaceKind _stringToPlaceKind(String content) {
  switch (content) {
    case "safe":
      return PlaceKind.safe;
    case "mine":
      return PlaceKind.mine;
    default:
      throw AssertionError();
  }
}

PlaceStateType _stringToPlaceStateType(String content) {
  switch (content) {
    case "closed":
      return PlaceStateType.closed;
    case "opened":
      return PlaceStateType.opened;
    case "flagged":
      return PlaceStateType.flagged;
    case "wronglyFlagged":
      return PlaceStateType.wronglyFlagged;
    case "exploded":
      return PlaceStateType.exploded;
    default:
      throw AssertionError();
  }
}
