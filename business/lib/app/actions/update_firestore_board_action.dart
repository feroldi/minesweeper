import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:business/app/actions/app_base_action.dart';
import 'package:business/app/models/app_state.dart';
import 'package:business/board/models/board_state.dart';
import 'package:business/board/models/place.dart';

class UpdateFirestoreBoardAction extends AppBaseAction {
  final List<Place> board;

  UpdateFirestoreBoardAction({this.board}) : assert(board != null);

  @override
  Future<AppState> reduce() async {
    await Firestore.instance
        .collection("boards")
        .document(boardState.boardID)
        .updateData({
      "board": board.map((place) => place.toJson()).toList(),
    });
    return null;
  }
}
