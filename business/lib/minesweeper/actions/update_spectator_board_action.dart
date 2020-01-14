import 'package:async_redux/async_redux.dart';

import 'package:business/minesweeper/actions/board_base_action.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/board_state.dart';

class UpdateSpectatorBoardAction extends BoardBaseAction {
  List<Place> updatedBoard;

  UpdateSpectatorBoardAction(this.updatedBoard);

  @override
  BoardState reduce() => state.updatePlaceStates(
        List<Place>.generate(
          state.options.dimensions.length,
          (index) => state.board[index].copyWith(
            kind: updatedBoard[index].kind,
            state: updatedBoard[index].state,
          ),
        ),
      );
}
