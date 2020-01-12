import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:business/minesweeper/actions/board_actions.dart';
import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/minesweeper/models/board_status.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:client/minesweeper/board_page_widget.dart';

class BoardPageConnector extends StatelessWidget {
  BoardPageConnector({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<BoardState, BoardPageViewModel>(
      model: BoardPageViewModel(),
      builder: (BuildContext context, BoardPageViewModel vm) => BoardPage(
        rows: vm.rows,
        columns: vm.columns,
        totalMines: vm.totalMines,
        boardData: vm.boardData,
        gameplayStatus: vm.gameplayStatus,
        onTileTap: vm.onTileTap,
        onTilePress: vm.onTilePress,
        onPlayerReactionButtonTap: vm.onPlayerReactionButtonTap,
      ),
    );
  }
}

class BoardPageViewModel extends BaseModel<BoardState> {
  BoardPageViewModel();

  int rows;
  int columns;
  int totalMines;
  List<Place> boardData;
  BoardStatus gameplayStatus;
  Function(Place place) onTileTap;
  Function(Place place) onTilePress;
  VoidCallback onPlayerReactionButtonTap;

  BoardPageViewModel.build({
    @required this.rows,
    @required this.columns,
    @required this.totalMines,
    @required this.boardData,
    @required this.gameplayStatus,
    @required this.onTileTap,
    @required this.onTilePress,
    @required this.onPlayerReactionButtonTap,
  }) : super(equals: [rows, columns, totalMines, boardData, gameplayStatus]);

  @override
  BoardPageViewModel fromStore() => BoardPageViewModel.build(
        rows: state.options.dimensions.rows,
        columns: state.options.dimensions.columns,
        totalMines: state.options.numMines,
        boardData: state.board,
        gameplayStatus: state.checkStatus(),
        onTileTap: (Place place) => dispatch(RevealPlacesAction(place)),
        onTilePress: (Place place) => dispatch(TogglePlaceAction(place)),
        onPlayerReactionButtonTap: () => dispatch(CreateRandomBoardAction()),
      );
}
