import 'package:async_redux/async_redux.dart';

import 'package:business/board/actions/board_command_action.dart';
import 'package:business/board/models/place.dart';
import 'package:business/board/models/place_kind.dart';
import 'package:business/board/models/place_state_type.dart';

class TriggerMineExplosionAction extends BoardCommandAction {
  @override
  List<Place> processBoardData() {
    final triggeredMinesBoard = boardState.board
        .map((place) => place.kind == PlaceKind.mine ||
                place.state == PlaceStateType.flagged
            ? Place.open(place)
            : place)
        .toList();
    return triggeredMinesBoard;
  }
}
