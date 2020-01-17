import 'package:async_redux/async_redux.dart';

import 'package:business/board/actions/board_command_action.dart';
import 'package:business/board/models/board_status.dart';
import 'package:business/board/models/place.dart';

class TogglePlaceAction extends BoardCommandAction {
  Place place;

  TogglePlaceAction(this.place) : assert(place != null);

  @override
  List<Place> processBoardData() {
    if (boardState.checkStatus() != BoardStatus.playing) return null;

    final newBoard = List.of(boardState.board);
    final originIndex = positionToIndex(place.pos);
    newBoard[originIndex] = Place.toggle(newBoard[originIndex]);

    return newBoard;
  }
}
