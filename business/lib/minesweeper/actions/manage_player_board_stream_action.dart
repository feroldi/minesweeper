import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:business/minesweeper/models/board_options.dart';
import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/minesweeper/models/board_status.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/pos.dart';

class ManagePlayerBoardStreamAction extends ReduxAction<BoardState> {
  String boardId;
  bool _startStream;

  static Stream<DocumentSnapshot> boardStream;
  static StreamSubscription<DocumentSnapshot> boardStreamSub;

  ManagePlayerBoardStreamAction.startStream({this.boardId}) : assert(boardId != null) {
    _startStream = true;
    boardStream = Firestore.instance.collection("boards").document(boardId).snapshots();
  }

  ManagePlayerBoardStreamAction.endStream() {
    _startStream = false;
  }

  @override
  BoardState reduce() {
    if (_startStream) {
      boardStream.listen((DocumentSnapshot boardDoc) {
        if (boardDoc.data == null || boardDoc.data.isEmpty) return;
      });
    }
  }
}
