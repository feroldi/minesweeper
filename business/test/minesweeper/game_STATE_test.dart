import 'package:test/test.dart';

import 'package:business/minesweeper/models/board_dimensions.dart';
import 'package:business/minesweeper/models/board_options.dart';
import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/minesweeper/models/board_status.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/pos.dart';

BoardState makeBoard({int rows, int columns, List<Pos> minePositions}) {
  return BoardState.generateBoardFromMinePositions(
    dimensions: BoardDimensions(rows: rows, columns: columns),
    minePositions: minePositions,
  );
}

void main() {
  test("A NxM board dimension has length N * M", () {
    final b3x3 = BoardDimensions(rows: 3, columns: 3);
    expect(b3x3.length, equals(3 * 3));

    final b5x8 = BoardDimensions(rows: 5, columns: 8);
    expect(b5x8.length, equals(5 * 8));
  });

  test("Boards with zeroed rows or columns cannot exist", () {
    expect(() => BoardDimensions(rows: 0, columns: 0),
        throwsA(isA<AssertionError>()));

    expect(() => BoardDimensions(rows: 0, columns: 1),
        throwsA(isA<AssertionError>()));

    expect(() => BoardDimensions(rows: 1, columns: 0),
        throwsA(isA<AssertionError>()));
  });

  test("Boards with less or more mines than specified cannot exist", () {
    final boardZeroMines = BoardState.generateBoardFromMinePositions(
        dimensions: BoardDimensions(rows: 2, columns: 2),
        minePositions: const <Pos>[]);

    expect(boardZeroMines.options.numMines, equals(0));

    final boardTwoMines = BoardState.generateBoardFromMinePositions(
        dimensions: BoardDimensions(rows: 2, columns: 2),
        minePositions: <Pos>[Pos(x: 0, y: 0), Pos(x: 1, y: 0)]);

    expect(boardTwoMines.options.numMines, equals(2));
  });

  test("Conversion between positions and indices are row-major", () {
    final board = makeBoard(rows: 5, columns: 4, minePositions: const []);

    expect(board.positionToIndex(Pos(x: 3, y: 0)), equals(3));
    expect(board.positionToIndex(Pos(x: 2, y: 1)), equals(2 + 5));
    expect(board.positionToIndex(Pos(x: 1, y: 2)), equals(1 + 5 * 2));

    expect(board.indexToPosition(3), equals(Pos(x: 3, y: 0)));
    expect(board.indexToPosition(2 + 5), equals(Pos(x: 2, y: 1)));
    expect(board.indexToPosition(1 + 5 * 2), equals(Pos(x: 1, y: 2)));
  });

  test("Generating a board without mines means all places are safe", () {
    final state = makeBoard(rows: 3, columns: 3, minePositions: const []);

    expect(state.board[0].kind, equals(PlaceKind.safe));
    expect(state.board[1].kind, equals(PlaceKind.safe));
    expect(state.board[2].kind, equals(PlaceKind.safe));
    expect(state.board[3].kind, equals(PlaceKind.safe));
    expect(state.board[4].kind, equals(PlaceKind.safe));
    expect(state.board[5].kind, equals(PlaceKind.safe));
    expect(state.board[6].kind, equals(PlaceKind.safe));
    expect(state.board[7].kind, equals(PlaceKind.safe));
    expect(state.board[8].kind, equals(PlaceKind.safe));
  });

  test("Generating a board from mine positions", () {
    final state = BoardState.generateBoardFromMinePositions(
        dimensions: BoardDimensions(rows: 3, columns: 3),
        minePositions: <Pos>[
          Pos(x: 0, y: 1),
          Pos(x: 1, y: 1),
          Pos(x: 1, y: 0)
        ]);

    expect(state.board[0].kind, equals(PlaceKind.safe));
    expect(state.board[1].kind, equals(PlaceKind.mine));
    expect(state.board[2].kind, equals(PlaceKind.safe));
    expect(state.board[3].kind, equals(PlaceKind.mine));
    expect(state.board[4].kind, equals(PlaceKind.mine));
    expect(state.board[5].kind, equals(PlaceKind.safe));
    expect(state.board[6].kind, equals(PlaceKind.safe));
    expect(state.board[7].kind, equals(PlaceKind.safe));
    expect(state.board[8].kind, equals(PlaceKind.safe));
  });

  test(
      "Adjacent mines only take into account neighbour places, excluding itself",
      () {
    final state = makeBoard(rows: 3, columns: 3, minePositions: <Pos>[
      Pos(x: 0, y: 1),
      Pos(x: 1, y: 1),
      Pos(x: 1, y: 0)
    ]);

    expect(state.placeAt(Pos(x: 1, y: 1)).neighbourMinesCount, equals(2));

    expect(state.placeAt(Pos(x: 0, y: 0)).neighbourMinesCount, equals(3));
  });
}
