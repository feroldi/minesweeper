import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:business/minesweeper/actions/update_spectator_board_action.dart';
import 'package:business/minesweeper/models/board_options.dart';
import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/minesweeper/models/board_status.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/player_type.dart';
import 'package:business/minesweeper/models/pos.dart';

class ManageSpectatorBoardStreamAction extends ReduxAction<BoardState> {
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
  BoardState reduce() {
    if (_startStream) {
      boardStreamSub = boardStream.listen((DocumentSnapshot boardDoc) {
        // TODO: Check if boardDoc.exists()
        if (boardDoc.data == null || boardDoc.data.isEmpty) return;

        final board = List.from(boardDoc["data"])
            .map((datum) => Place(
                kind: _stringToPlaceKind(datum["kind"]),
                state: _stringToPlaceStateType(datum["state"])))
            .toList();

        dispatch(UpdateSpectatorBoardAction(board));
      });
    } else {
      boardStreamSub.cancel();
    }

    return state.copyWith(playerType: PlayerType.spectator);
  }
}

PlaceKind _stringToPlaceKind(String content) {
  switch (content) {
    case "safe":
      return PlaceKind.safe;
    case "mine":
      return PlaceKind.mine;
    default:
      throw AssertionError();
  }
}

PlaceStateType _stringToPlaceStateType(String content) {
  switch (content) {
    case "closed":
      return PlaceStateType.closed;
    case "opened":
      return PlaceStateType.opened;
    case "flagged":
      return PlaceStateType.flagged;
    case "wronglyFlagged":
      return PlaceStateType.wronglyFlagged;
    case "exploded":
      return PlaceStateType.exploded;
    default:
      throw AssertionError();
  }
}
