import 'dart:math';

import 'package:business/minesweeper/models/board_dimensions.dart';
import 'package:business/minesweeper/models/board_options.dart';
import 'package:business/minesweeper/models/board_status.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/player_type.dart';
import 'package:business/minesweeper/models/pos.dart';

class BoardState {
  String boardID;
  BoardOptions options;
  List<Place> board;
  PlayerType playerType;

  BoardState({
    this.boardID,
    this.options,
    this.board,
    this.playerType = PlayerType.player,
  });

  BoardState copyWith({
    String boardID,
    BoardOptions options,
    List<Place> board,
    PlayerType playerType,
  }) =>
      BoardState(
        boardID: boardID ?? this.boardID,
        options: options ?? this.options,
        board: board ?? this.board,
        playerType: playerType ?? this.playerType,
      );

  int positionToIndex(Pos pos) => options.dimensions.positionToIndex(pos);

  Pos indexToPosition(int index) => options.dimensions.indexToPosition(index);

  bool isPosInBounds(Pos pos) => options.dimensions.isPosInBounds(pos);

  Place placeAt(Pos pos) => board[positionToIndex(pos)];

  factory BoardState.generateBoardFromMinePositions(
      {BoardDimensions dimensions, List<Pos> minePositions}) {
    final board = List<Place>.generate(dimensions.length,
        (index) => Place(pos: dimensions.indexToPosition(index)));

    for (final minePos in minePositions) {
      assert(dimensions.isPosInBounds(minePos));
      final mineIndex = dimensions.positionToIndex(minePos);
      board[mineIndex] = Place.asMine(board[mineIndex]);
    }

    final options =
        BoardOptions(dimensions: dimensions, numMines: minePositions.length);

    return BoardState(
      options: options,
      board: _computeNeighbourMinesCount(dimensions, board),
    );
  }

  factory BoardState.generateRandomBoard({BoardOptions options, Random rand}) {
    final kinds = List<PlaceKind>.generate(options.dimensions.length,
        (index) => index < options.numMines ? PlaceKind.mine : PlaceKind.safe);
    kinds.shuffle(rand);
    final board = List<Place>.generate(
        options.dimensions.length,
        (index) => Place(
            pos: options.dimensions.indexToPosition(index),
            kind: kinds[index]));
    return BoardState(
      options: options,
      board: _computeNeighbourMinesCount(options.dimensions, board),
    );
  }

  BoardState updatePlaceStates(List<Place> places) {
    final board = List<Place>.generate(options.dimensions.length,
        (index) => places[index].copyWith(pos: indexToPosition(index)));
    return this.copyWith(
      board: _computeNeighbourMinesCount(options.dimensions, board),
    );
  }

  Iterable<Place> findPlaceNeighbours(Place place) =>
      _findPlaceNeighbours(options.dimensions, board, place);

  BoardStatus checkStatus() {
    final anyTriggeredMine = board.any((place) =>
        place.kind == PlaceKind.mine && isRevealedState(place.state));

    if (anyTriggeredMine) return BoardStatus.defeat;

    // All mines have to be flagged, and there can't be any closed places.
    // We could do better without a linear search algorithm, e.g., storing the
    // flagged and closed places count and updating after toggle/reveal
    // actions. But this is good enough for this project.
    final flaggedMinesCount = board.fold(
        0,
        (numClosed, place) =>
            numClosed +
            (place.state == PlaceStateType.flagged &&
                    place.kind == PlaceKind.mine
                ? 1
                : place.state == PlaceStateType.closed ? -1 : 0));

    return flaggedMinesCount == options.numMines
        ? BoardStatus.victory
        : BoardStatus.playing;
  }
}

List<Place> _computeNeighbourMinesCount(
    BoardDimensions dimensions, List<Place> board) {
  return board
      .map((place) => place.copyWith(
          neighbourMinesCount: _findPlaceNeighbours(dimensions, board, place)
              .where((neighbour) => neighbour.kind == PlaceKind.mine)
              .toList()
              .length))
      .toList();
}

Iterable<Place> _findPlaceNeighbours(
    BoardDimensions dimensions, List<Place> board, Place place) sync* {
  for (final i in const [-1, 0, 1]) {
    for (final j in const [-1, 0, 1]) {
      if (i == 0 && j == 0) continue;
      final neighbourPos = Pos(x: place.pos.x + i, y: place.pos.y + j);
      if (dimensions.isPosInBounds(neighbourPos)) {
        yield board[dimensions.positionToIndex(neighbourPos)];
      }
    }
  }
}
