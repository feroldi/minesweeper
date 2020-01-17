import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:business/app/models/app_state.dart';
import 'package:business/app/actions/app_base_action.dart';
import 'package:business/board/models/board_state.dart';

class CreateFirestoreBoardAction extends AppBaseAction {
  @override
  Future<AppState> reduce() async {
    final boardRef = Firestore.instance.collection("boards").document();
    await boardRef.setData(boardState.toJson());
    return state.copyWith(
      boardState: boardState.copyWith(boardID: boardRef.documentID),
    );
  }
}
