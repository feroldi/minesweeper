import 'package:async_redux/async_redux.dart';

import 'package:business/app/actions/app_base_action.dart';
import 'package:business/app/models/app_state.dart';
import 'package:business/board/models/board_state.dart';
import 'package:business/board/models/place.dart';
import 'package:business/board/models/pos.dart';

abstract class BoardBaseAction extends AppBaseAction {
  BoardState reduceBoardState();

  @override
  AppState reduce() {
    final boardState = reduceBoardState();
    return boardState != null ? state.copyWith(boardState: boardState) : null;
  }

  int positionToIndex(Pos pos) => boardState.positionToIndex(pos);
  Pos indexToPosition(int index) => boardState.indexToPosition(index);
  bool isPosInBounds(Pos pos) => boardState.isPosInBounds(pos);

  Iterable<Place> findPlaceNeighbours(Place place) =>
      boardState.findPlaceNeighbours(place);
}
