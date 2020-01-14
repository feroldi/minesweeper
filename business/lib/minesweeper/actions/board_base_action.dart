import 'package:async_redux/async_redux.dart';

import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/pos.dart';

abstract class BoardBaseAction extends ReduxAction<BoardState> {
  int positionToIndex(Pos pos) => state.positionToIndex(pos);
  Pos indexToPosition(int index) => state.indexToPosition(index);
  bool isPosInBounds(Pos pos) => state.isPosInBounds(pos);

  Iterable<Place> findPlaceNeighbours(Place place) =>
      state.findPlaceNeighbours(place);
}
