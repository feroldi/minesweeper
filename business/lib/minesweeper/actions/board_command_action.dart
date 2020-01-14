import 'package:async_redux/async_redux.dart';

import 'package:business/minesweeper/actions/board_base_action.dart';
import 'package:business/minesweeper/actions/update_firestore_board_action.dart';
import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/minesweeper/models/place.dart';

abstract class BoardCommandAction extends BoardBaseAction {
  List<Place> reduceBoard();

  @override
  BoardState reduce() {
    final board = reduceBoard();
    if (state.boardID != null && board != null) {
      dispatch(UpdateFirestoreBoardAction(board: board));
    }
    return state.copyWith(board: board);
  }
}
