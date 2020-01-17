import 'package:business/board/actions/board_base_action.dart';
import 'package:business/board/models/board_options.dart';
import 'package:business/board/models/board_state.dart';
import 'package:business/board/models/place.dart';

class UpdateSpectatorBoardAction extends BoardBaseAction {
  BoardOptions options;
  List<Place> boardData;

  UpdateSpectatorBoardAction({this.options, this.boardData});

  @override
  BoardState reduceBoardState() =>
      boardState.copyWith(options: options, board: boardData);
}
