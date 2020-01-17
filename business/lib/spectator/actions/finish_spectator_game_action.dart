import 'package:business/app/actions/app_base_action.dart';
import 'package:business/app/models/app_state.dart';
import 'package:business/spectator/actions/manage_spectator_board_stream_action.dart';

class FinishSpectatorGameAction extends AppBaseAction {
  @override
  AppState reduce() {
    dispatch(ManageSpectatorBoardStreamAction.endStream());
    return state.copyWith(
      boardState: BoardState.initialState(),
    );
  }

  @override
  void after() => dispatch(NavigateAction<AppState>.pushReplacementNamed('/'));
}
