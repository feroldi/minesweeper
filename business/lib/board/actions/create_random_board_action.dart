import 'package:async_redux/async_redux.dart';

import 'package:business/board/actions/board_base_action.dart';
import 'package:business/board/models/board_options.dart';
import 'package:business/board/models/board_state.dart';

class CreateRandomBoardAction extends BoardBaseAction {
  BoardOptions options;

  CreateRandomBoardAction({this.options});

  @override
  BoardState reduceBoardState() =>
      BoardState.generateRandomBoard(options: options ?? boardState.options);
}
