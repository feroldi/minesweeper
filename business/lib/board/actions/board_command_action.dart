import 'dart:core';

import 'package:async_redux/async_redux.dart';

import 'package:business/app/actions/update_firestore_board_action.dart';
import 'package:business/board/actions/board_base_action.dart';
import 'package:business/board/models/board_state.dart';
import 'package:business/board/models/place.dart';

abstract class BoardCommandAction extends BoardBaseAction {
  List<Place> processBoardData();

  @override
  BoardState reduceBoardState() {
    final board = processBoardData();

    if (boardState.boardID != null && board != null) {
      dispatch(UpdateFirestoreBoardAction(board: board));
    }

    return boardState.copyWith(board: board);
  }
}
