import 'package:async_redux/async_redux.dart';
import 'package:meta/meta.dart';

import 'package:business/minesweeper/models/board_dimensions.dart';
import 'package:business/minesweeper/models/game_options.dart';
import 'package:business/minesweeper/models/game_state.dart';
import 'package:business/minesweeper/models/game_util.dart';

class PlayNewGameAction extends ReduxAction<GameState> {
  final int rows;
  final int columns;
  final int mines;

  PlayNewGameAction(
      {@required this.rows, @required this.columns, @required this.mines})
      : assert(rows != null && columns != null && mines != null);

  @override
  GameState reduce() {
    if (rows * columns <= mines) {
      throw UserException("Number of mines is too big for this board.");
    }

    return GameState.fromOptions(GameOptions(
        dimensions: BoardDimensions(rows: rows, columns: columns),
        numMines: mines));
  }
}
