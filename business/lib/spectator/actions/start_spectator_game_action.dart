import 'package:business/app/actions/app_base_action.dart';
import 'package:business/minesweeper/models/app_state.dart';
import 'package:business/spectator/actions/manage_spectator_board_stream_action.dart';

final spectatorBoardRoute = "/spectatorBoardRoute";

class StartSpectatorGameAction extends AppBaseAction {
  String boardID;

  StartSpectatorGameAction({this.boardID}) : assert(boardID != null);

  @override
  AppState reduce() {
    dispatch(ManageSpectatorBoardStreamAction.startStream(boardID: boardID));
    return null;
  }
}
