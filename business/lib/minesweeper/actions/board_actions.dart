import 'dart:collection';

import 'package:async_redux/async_redux.dart';
import 'package:meta/meta.dart';

import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/pos.dart';

abstract class BoardBaseAction extends ReduxAction<BoardState> {
  int positionToIndex(Pos pos) => state.positionToIndex(pos);
  Pos indexToPosition(int index) => state.indexToPosition(index);
  bool isPosInBounds(Pos pos) => state.isPosInBounds(pos);

  Iterable<Place> findPlaceNeighbours(Place place) =>
      state.findPlaceNeighbours(place);
}

class TogglePlaceAction extends BoardBaseAction {
  Place place;

  TogglePlaceAction(this.place) : assert(place != null);

  @override
  BoardState reduce() {
    final newBoard = List.of(state.board);
    final originIndex = positionToIndex(place.pos);
    newBoard[originIndex] = Place.toggle(newBoard[originIndex]);
    return state.copyWith(board: newBoard);
  }
}

class RevealPlacesAction extends BoardBaseAction {
  Place origin;

  RevealPlacesAction(this.origin) : assert(origin != null);

  @override
  BoardState reduce() {
    if (origin.state != PlaceStateType.closed) return null;

    if (origin.kind == PlaceKind.mine) {
      dispatch(TriggerMineExplosionAction());
      return null;
    }

    final queue = Queue<Pos>()..add(origin.pos);
    final visitedPlaces = HashSet<Pos>();
    final revealedPlaces = Map<int, Place>();

    // A BFS in the wild? My bachelor is finally starting to pay off! /s
    while (queue.isNotEmpty) {
      final placePos = queue.removeFirst();
      final place = state.board[positionToIndex(placePos)];

      if (place.state == PlaceStateType.closed &&
          place.kind != PlaceKind.mine) {
        revealedPlaces.putIfAbsent(
            positionToIndex(place.pos), () => Place.open(place));

        if (place.neighbourMinesCount == 0) {
          final neighbours = findPlaceNeighbours(place)
              .where((neighbour) => !visitedPlaces.contains(neighbour.pos))
              .map((neighbour) => neighbour.pos)
              .toList();

          // Note that we also mark our neighbours as visited places. This is
          // done to filter out already queued neighbours when computing a
          // place's neighbour.
          queue.addAll(neighbours);
          visitedPlaces.addAll(neighbours);
        }
      }
    }

    final newBoard = List<Place>();
    state.board.asMap().forEach(
        (index, place) => newBoard.add(revealedPlaces[index] ?? place));

    return state.copyWith(
      board: newBoard,
    );
  }
}

class TriggerMineExplosionAction extends BoardBaseAction {
  @override
  BoardState reduce() {
    final triggeredMinesBoard = state.board
        .map((place) => place.kind == PlaceKind.mine ||
                place.state == PlaceStateType.flagged
            ? Place.open(place)
            : place)
        .toList();
    return state.copyWith(board: triggeredMinesBoard);
  }
}
