import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:business/app/actions/app_base_action.dart';
import 'package:business/app/models/app_state.dart';

class CreateGameStreamAction extends AppBaseAction {
  @override
  Future<AppState> reduce() {
    assert(
        boardState.boardID == null, "A game stream has already been created!");
    final boardRef = Firestore.instance.collection("boards").document();
    await boardRef.setData(boardState.toJson());
    return state.copyWith(
      boardState: boardState.copyWith(boardID: boardRef.documentID),
      gameStartedStreamingEvt: Event<String>(boardRef.documentID),
    );
  }
}
