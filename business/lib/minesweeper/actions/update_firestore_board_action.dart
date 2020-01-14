import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:business/minesweeper/actions/board_base_action.dart';
import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/minesweeper/models/place.dart';

class UpdateFirestoreBoardAction extends BoardBaseAction {
  final List<Place> board;

  UpdateFirestoreBoardAction({this.board}) : assert(board != null);

  @override
  Future<BoardState> reduce() async {
    await Firestore.instance
        .collection("boards")
        .document(state.boardID)
        .updateData({
      "data": board.map((place) => place.toJson()).toList(),
    });
    return null;
  }
}
