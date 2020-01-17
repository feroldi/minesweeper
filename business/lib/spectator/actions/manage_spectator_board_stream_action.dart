import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:business/aoo/models/app_state.dart';
import 'package:business/app/actions/app_base_action.dart';
import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/spectator/actions/update_spectator_board_action.dart';

class ManageSpectatorBoardStreamAction extends AppBaseAction {
  String boardID;
  bool _startStream;

  static Stream<DocumentSnapshot> boardStream;
  static StreamSubscription<DocumentSnapshot> boardStreamSub;

  ManageSpectatorBoardStreamAction.startStream({this.boardID})
      : assert(boardID != null) {
    _startStream = true;
    boardStream =
        Firestore.instance.collection("boards").document(boardID).snapshots();
  }

  ManageSpectatorBoardStreamAction.endStream() {
    _startStream = false;
  }

  @override
  Future<AppState> reduce() async {
    if (_startStream) {
      final boardFirstSnapshot = await boardStream.first;

      if (!boardFirstSnapshot.exists ||
          boardFirstSnapshot.data == null ||
          boardFirstSnapshot.data.isEmpty) {
        throw UserException(
            "A board for this ID couldn't be found: '$boardID'");
      }

      boardStreamSub = boardStream.listen((DocumentSnapshot boardSnapshot) {
        if (boardSnapshot.data != null && boardSnapshot.data.isNotEmpty) {
          if (boardSnapshot["gameState"] == "exited") {
            dispatch(FinishSpectatorGameAction());
            return;
          }

          final newBoardState =
              BoardState.fromJson(boardSnapshot.data.cast<String, dynamic>());

          dispatch(UpdateSpectatorBoardAction(
            options: newBoardState.options,
            boardData: newBoardState.board,
          ));
        }
      });

      dispatch(
          NavigateAction<AppState>.pushReplacementNamed(spectatorBoardRoute));

      return state.copyWith(
        boardState: BoardState.fromJson(
            boardFirstSnapshot.data.cast<String, dynamic>()),
      );
    } else {
      await Future.value(null);
      boardStreamSub.cancel();
    }

    return null;
  }
}
