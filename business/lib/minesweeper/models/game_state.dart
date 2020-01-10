import 'dart:math';
import 'dart:collection';

import 'package:business/minesweeper/models/board_dimensions.dart';
import 'package:business/minesweeper/models/board_status.dart';
import 'package:business/minesweeper/models/game_options.dart';
import 'package:business/minesweeper/models/game_util.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/pos.dart';

class GameState {
  GameUtil gameUtil;
  List<Place> board;
  bool isPlaying;

  GameState({this.gameUtil, this.board, this.isPlaying});

  int get boardRows => gameUtil.options.dimensions.rows;
  int get boardColumns => gameUtil.options.dimensions.columns;
  int get boardLength => gameUtil.options.dimensions.length;
  int get totalMines => gameUtil.options.numMines;

  BoardStatus get boardStatus {
    assert(isPlaying);
    return gameUtil.checkBoardStatus(board);
  }

  factory GameState.initialState() {
    // This is the closest to a "default" state I can think of. We could
    // generate a random board from a 5x10 board dimension, but that'd make
    // initialState non-deterministic, which doesn't really sound very nice.
    final gameUtil = GameUtil(
      options: GameOptions(
        dimensions: BoardDimensions(
          rows: 1,
          columns: 1,
        ),
        numMines: 0,
      ),
    );

    return GameState(
      gameUtil: gameUtil,
      board: <Place>[],
      isPlaying: false,
    );
  }

  factory GameState.fromOptions(GameOptions options) => GameState(
        gameUtil: GameUtil(options: options),
        board: GameUtil(options: options).generateRandomBoard(),
        isPlaying: true,
      );

  GameState copyWith({GameUtil gameUtil, List<Place> board, bool isPlaying}) => GameState(
        gameUtil: gameUtil ?? this.gameUtil,
        board: board ?? this.board,
        isPlaying: isPlaying ?? this.isPlaying,
      );
}
