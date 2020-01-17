import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:business/app/actions/app_base_action.dart';
import 'package:business/app/models/app_state.dart';
import 'package:business/board/models/board_state.dart';

class LookupGameAction extends AppBaseAction {
  String boardID;

  LookupGameAction({this.boardID}) : assert(boardID != null);

  @override
  Future<AppState> reduce() async {
    final boardSnapshots = Firestore.instance.collection("boards").document(boardID).snapshots();
    final boardFirstSnap = await boardSnapshots.first;

    if (boardFirstSnap.exists && boardFirstSnap.data != null && boardFirstSnap.data.isNotEmpty) {
      if (
    } else {
      throw UserException("The board '$boardID' couldn't be found");
    }
  }
}
