import 'package:business/app/actions/app_base_action.dart';
import 'package:business/app/models/app_state.dart';
import 'package:business/board/actions/create_random_board_action.dart';
import 'package:business/board/models/board_dimensions.dart';
import 'package:business/board/models/board_options.dart';
import 'package:business/board/models/board_state.dart';

final playerBoardRoute = "/playerBoardRoute";

class StartPlayerGameAction extends AppBaseAction {
  int rows;
  int columns;
  int mines;

  StartPlayerGameAction({this.rows, this.columns, this.mines})
      : assert(rows != null && columns != null && mines != null);

  @override
  AppState reduce() {
    if (rows < 1 || rows > 10) {
      throw UserException(
          "Rows should be greater than 0 and lower than or equal to 10.");
    } else if (columns < 1 || columns > 15) {
      throw UserException(
          "Columns should be greater than 0 and lower than or equal to 15.");
    } else if (mines <= 0) {
      throw UserException("Number of mines should be greater than zero.");
    } else if (mines >= rows * columns) {
      throw UserException("Number of mines is too big for this board.");
    } else {
      final boardOptions = BoardOptions(
        dimensions: BoardDimensions(
          rows: rows,
          columns: columns,
        ),
        numMines: mines,
      );

      dispatch(NavigateAction<AppState>.pushReplacementNamed(playerBoardRoute));

      return state.copyWith(
        boardState: BoardState.generateRandomBoard(options: boardOptions),
      );
    }

    return null;
  }
}
