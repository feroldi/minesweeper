import 'dart:math';

import 'package:business/minesweeper/models/board_dimensions.dart';
import 'package:business/minesweeper/models/board_options.dart';
import 'package:business/minesweeper/models/board_status.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/pos.dart';

class BoardState {
  BoardOptions options;
  List<Place> board;

  BoardState({this.options, this.board});

  BoardState copyWith({BoardOptions options, List<Place> board}) =>
      BoardState(options: options ?? this.options, board: board ?? this.board);

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

  Iterable<Place> findPlaceNeighbours(Place place) =>
      _findPlaceNeighbours(options.dimensions, board, place);

  BoardStatus checkStatus() {
    final anyTriggeredMine = board.any((place) =>
        place.kind == PlaceKind.mine && isRevealedState(place.state));

    if (anyTriggeredMine) return BoardStatus.defeat;

    final remainingClosedPlaces = board.fold(
        0,
        (numClosed, place) =>
            numClosed + (isRevealedState(place.state) ? 0 : 1));

    return remainingClosedPlaces <= options.numMines
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
