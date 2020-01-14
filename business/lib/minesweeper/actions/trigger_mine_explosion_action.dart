import 'package:async_redux/async_redux.dart';

import 'package:business/minesweeper/actions/board_command_action.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/player_type.dart';

class TriggerMineExplosionAction extends BoardCommandAction {
  @override
  Set<PlayerType> whoCanExecute() {
    return const {PlayerType.player, PlayerType.spectator};
  }

  @override
  List<Place> reduceBoard() {
    final triggeredMinesBoard = state.board
        .map((place) => place.kind == PlaceKind.mine ||
                place.state == PlaceStateType.flagged
            ? Place.open(place)
            : place)
        .toList();
    return triggeredMinesBoard;
  }
}