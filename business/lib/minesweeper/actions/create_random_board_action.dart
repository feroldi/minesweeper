import 'package:async_redux/async_redux.dart';

import 'package:business/minesweeper/actions/board_base_action.dart';
import 'package:business/minesweeper/actions/manage_spectator_board_stream_action.dart';
import 'package:business/minesweeper/models/board_options.dart';
import 'package:business/minesweeper/models/board_state.dart';

class CreateRandomBoardAction extends BoardBaseAction {
  BoardOptions options;

  CreateRandomBoardAction({this.options});

  @override
  BoardState reduce() {
    if (state.boardID != null)
      dispatch(ManageSpectatorBoardStreamAction.endStream());
    return BoardState.generateRandomBoard(options: options ?? state.options);
  }
}
