import 'dart:collection';

import 'package:async_redux/async_redux.dart';

import 'package:business/board/actions/board_command_action.dart';
import 'package:business/board/actions/trigger_mine_explosion_action.dart';
import 'package:business/board/models/board_status.dart';
import 'package:business/board/models/place.dart';
import 'package:business/board/models/place_kind.dart';
import 'package:business/board/models/place_state_type.dart';
import 'package:business/board/models/pos.dart';

class RevealPlacesAction extends BoardCommandAction {
  Place origin;

  RevealPlacesAction(this.origin) : assert(origin != null);

  @override
  List<Place> processBoardData() {
    if (origin.state != PlaceStateType.closed) return null;

    if (origin.kind == PlaceKind.mine) {
      dispatch(TriggerMineExplosionAction());
      return null;
    }

    final queue = Queue<Pos>()..add(origin.pos);
    final visitedPlaces = HashSet<Pos>();
    final revealedPlaces = Map<int, Place>();

    while (queue.isNotEmpty) {
      final placePos = queue.removeFirst();
      final place = boardState.board[positionToIndex(placePos)];

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
    boardState.board.asMap().forEach(
        (index, place) => newBoard.add(revealedPlaces[index] ?? place));

    return newBoard;
  }
}
