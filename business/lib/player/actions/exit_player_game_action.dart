import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:business/app/actions/app_base_action.dart';
import 'package:business/app/models/app_state.dart';
import 'package:business/board/models/board_state.dart';

class ExitPlayerGameAction extends AppBaseAction {
  @override
  AppState reduce() {
    if (boardState.boardID != null) {
      await Firestore.instance
          .collection("boards")
          .document(boardState.boardID)
          .setData({"gameState": "exited"});
    }

    return state.copyWith(
      boardState: BoardState.initialState(),
    );
  }

  @override
  void after() => dispatch(NavigateAction<AppState>.pushReplacementNamed('/'));
}
