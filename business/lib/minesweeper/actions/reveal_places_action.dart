import 'dart:collection';

import 'package:async_redux/async_redux.dart';

import 'package:business/minesweeper/actions/board_command_action.dart';
import 'package:business/minesweeper/actions/trigger_mine_explosion_action.dart';
import 'package:business/minesweeper/models/board_status.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/pos.dart';

class RevealPlacesAction extends BoardCommandAction {
  Place origin;

  RevealPlacesAction(this.origin) : assert(origin != null);

  @override
  List<Place> reduceBoard() {
    if (state.checkStatus() != BoardStatus.playing) return null;

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

    return newBoard;
  }
}
