import 'package:async_redux/async_redux.dart';

import 'package:business/minesweeper/actions/board_command_action.dart';
import 'package:business/minesweeper/models/board_status.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/player_type.dart';

class TogglePlaceAction extends BoardCommandAction {
  Place place;

  TogglePlaceAction(this.place) : assert(place != null);

  @override
  List<PlayerType> whoCanExecute() {
    return const [PlayerType.player];
  }

  @override
  List<Place> reduceBoard() {
    if (state.checkStatus() != BoardStatus.playing) return null;

    final newBoard = List.of(state.board);
    final originIndex = positionToIndex(place.pos);
    newBoard[originIndex] = Place.toggle(newBoard[originIndex]);

    return newBoard;
  }
}
