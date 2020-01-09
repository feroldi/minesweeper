import 'package:test/test.dart';

import 'package:business/minesweeper/models/board_dimensions.dart';
import 'package:business/minesweeper/models/game_options.dart';
import 'package:business/minesweeper/models/game_state.dart';
import 'package:business/minesweeper/models/game_state_type.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/pos.dart';

GameState makeGame({int rows, int columns, int numMines}) {
  return GameState(
      options: GameOptions(
          dimensions: BoardDimensions(rows: rows, columns: columns),
          numMines: numMines));
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
    final game = makeGame(rows: 2, columns: 2, numMines: 1);

    expect(() => game.generateBoardFromMinePositions(<Pos>[]),
        throwsA(isA<AssertionError>()));

    expect(
        () => game.generateBoardFromMinePositions(
            <Pos>[Pos(x: 0, y: 0), Pos(x: 1, y: 0)]),
        throwsA(isA<AssertionError>()));
  });

  test("Conversion between positions and indices are row-major", () {
    final game = makeGame(rows: 5, columns: 4, numMines: 0);

    expect(game.positionToIndex(Pos(x: 3, y: 0)), equals(3));
    expect(game.positionToIndex(Pos(x: 2, y: 1)), equals(2 + 5));
    expect(game.positionToIndex(Pos(x: 1, y: 2)), equals(1 + 5 * 2));

    expect(game.indexToPosition(3), equals(Pos(x: 3, y: 0)));
    expect(game.indexToPosition(2 + 5), equals(Pos(x: 2, y: 1)));
    expect(game.indexToPosition(1 + 5 * 2), equals(Pos(x: 1, y: 2)));
  });

  test("Generating a board without mines means all places are safe", () {
    final game = makeGame(rows: 3, columns: 3, numMines: 0);
    final board = game.generateBoardFromMinePositions(<Pos>[]);

    expect(board[0].kind, equals(PlaceKind.safe));
    expect(board[1].kind, equals(PlaceKind.safe));
    expect(board[2].kind, equals(PlaceKind.safe));
    expect(board[3].kind, equals(PlaceKind.safe));
    expect(board[4].kind, equals(PlaceKind.safe));
    expect(board[5].kind, equals(PlaceKind.safe));
    expect(board[6].kind, equals(PlaceKind.safe));
    expect(board[7].kind, equals(PlaceKind.safe));
    expect(board[8].kind, equals(PlaceKind.safe));
  });

  test("Generating a board from mine positions", () {
    final game = makeGame(rows: 3, columns: 3, numMines: 3);
    final board = game.generateBoardFromMinePositions(
        <Pos>[Pos(x: 0, y: 1), Pos(x: 1, y: 1), Pos(x: 1, y: 0)]);

    expect(board[0].kind, equals(PlaceKind.safe));
    expect(board[1].kind, equals(PlaceKind.mine));
    expect(board[2].kind, equals(PlaceKind.safe));
    expect(board[3].kind, equals(PlaceKind.mine));
    expect(board[4].kind, equals(PlaceKind.mine));
    expect(board[5].kind, equals(PlaceKind.safe));
    expect(board[6].kind, equals(PlaceKind.safe));
    expect(board[7].kind, equals(PlaceKind.safe));
    expect(board[8].kind, equals(PlaceKind.safe));
  });

  test(
      "Adjacent mines only take into account neighbour places, excluding itself",
      () {
    final game = makeGame(rows: 3, columns: 3, numMines: 3);
    final board = game.generateBoardFromMinePositions(
        <Pos>[Pos(x: 0, y: 1), Pos(x: 1, y: 1), Pos(x: 1, y: 0)]);

    expect(board[game.positionToIndex(Pos(x: 1, y: 1))].neighbourMinesCount,
        equals(2));

    expect(board[game.positionToIndex(Pos(x: 0, y: 0))].neighbourMinesCount,
        equals(3));
  });

  test("Do not reveal neighbours when there are mines around", () {
    final game = makeGame(rows: 2, columns: 2, numMines: 1);
    final board = game.generateBoardFromMinePositions(<Pos>[Pos(x: 1, y: 0)]);
    final revealedBoard = game.revealPlaces(board, Pos(x: 0, y: 1));

    expect(revealedBoard[0].kind, equals(PlaceKind.safe));
    expect(revealedBoard[1].kind, equals(PlaceKind.mine));
    expect(revealedBoard[2].kind, equals(PlaceKind.safe));
    expect(revealedBoard[3].kind, equals(PlaceKind.safe));

    expect(revealedBoard[0].state, equals(PlaceStateType.closed));
    expect(revealedBoard[1].state, equals(PlaceStateType.closed));
    expect(revealedBoard[2].state, equals(PlaceStateType.opened));
    expect(revealedBoard[3].state, equals(PlaceStateType.closed));
  });

  test(
      "Reveal neighbours of a place that is not a mine and has zero adjacent mines",
      () {
    final game = makeGame(rows: 3, columns: 3, numMines: 1);
    final board = game.generateBoardFromMinePositions(<Pos>[Pos(x: 2, y: 0)]);
    final revealedBoard = game.revealPlaces(board, Pos(x: 0, y: 2));

    expect(revealedBoard[0].kind, equals(PlaceKind.safe));
    expect(revealedBoard[1].kind, equals(PlaceKind.safe));
    expect(revealedBoard[2].kind, equals(PlaceKind.mine));
    expect(revealedBoard[3].kind, equals(PlaceKind.safe));
    expect(revealedBoard[4].kind, equals(PlaceKind.safe));
    expect(revealedBoard[5].kind, equals(PlaceKind.safe));
    expect(revealedBoard[6].kind, equals(PlaceKind.safe));
    expect(revealedBoard[7].kind, equals(PlaceKind.safe));
    expect(revealedBoard[8].kind, equals(PlaceKind.safe));

    expect(revealedBoard[0].state, equals(PlaceStateType.opened));
    expect(revealedBoard[1].state, equals(PlaceStateType.opened));
    expect(revealedBoard[2].state, equals(PlaceStateType.closed));
    expect(revealedBoard[3].state, equals(PlaceStateType.opened));
    expect(revealedBoard[4].state, equals(PlaceStateType.opened));
    expect(revealedBoard[5].state, equals(PlaceStateType.opened));
    expect(revealedBoard[6].state, equals(PlaceStateType.opened));
    expect(revealedBoard[7].state, equals(PlaceStateType.opened));
    expect(revealedBoard[8].state, equals(PlaceStateType.opened));
  });

  test("Opening a mine triggers all other mines to explode", () {
    final game = makeGame(rows: 3, columns: 1, numMines: 2);
    final boardStart = game.generateBoardFromMinePositions(
        <Pos>[Pos(x: 1, y: 0), Pos(x: 2, y: 0)]);

    final triggeredMineBoard = game.revealPlaces(boardStart, Pos(x: 1, y: 0));

    expect(triggeredMineBoard[0].kind, equals(PlaceKind.safe));
    expect(triggeredMineBoard[1].kind, equals(PlaceKind.mine));
    expect(triggeredMineBoard[2].kind, equals(PlaceKind.mine));

    expect(triggeredMineBoard[0].state, equals(PlaceStateType.closed));
    expect(triggeredMineBoard[1].state, equals(PlaceStateType.exploded));
    expect(triggeredMineBoard[2].state, equals(PlaceStateType.exploded));
  });

  test("Toggling a place marks it as flagged and closed back and forth", () {
    final game = makeGame(rows: 1, columns: 1, numMines: 0);
    final boardStart = game.generateBoardFromMinePositions(<Pos>[]);

    final flaggedBoard = game.togglePlace(
        boardStart, boardStart[game.positionToIndex(Pos(x: 0, y: 0))]);

    expect(flaggedBoard[0].state, equals(PlaceStateType.flagged));

    final unflaggedBoard = game.togglePlace(
        flaggedBoard, flaggedBoard[game.positionToIndex(Pos(x: 0, y: 0))]);

    expect(unflaggedBoard[0].state, equals(PlaceStateType.closed));
  });

  test("Places other than closed and flagged cannot be toggled", () {
    final game = makeGame(rows: 1, columns: 1, numMines: 0);
    final boardStart = game.generateBoardFromMinePositions(<Pos>[]);
    final openedBoard = game.revealPlaces(boardStart, Pos(x: 0, y: 0));
    final flaggedBoard = game.togglePlace(
        openedBoard, openedBoard[game.positionToIndex(Pos(x: 0, y: 0))]);

    expect(flaggedBoard[0].state, equals(PlaceStateType.opened));
  });

  test("A flagged mine should be stated as wrong after defeat", () {
    final game = makeGame(rows: 3, columns: 1, numMines: 2);
    final boardStart = game.generateBoardFromMinePositions(
        <Pos>[Pos(x: 1, y: 0), Pos(x: 2, y: 0)]);
    final toggledMineBoard = game.togglePlace(
        boardStart, boardStart[game.positionToIndex(Pos(x: 1, y: 0))]);
    final triggeredMineBoard =
        game.revealPlaces(toggledMineBoard, Pos(x: 2, y: 0));

    expect(triggeredMineBoard[0].kind, equals(PlaceKind.safe));
    expect(triggeredMineBoard[1].kind, equals(PlaceKind.mine));
    expect(triggeredMineBoard[2].kind, equals(PlaceKind.mine));

    expect(triggeredMineBoard[0].state, equals(PlaceStateType.closed));
    expect(triggeredMineBoard[1].state, equals(PlaceStateType.flagExploded));
    expect(triggeredMineBoard[2].state, equals(PlaceStateType.exploded));
  });

  test("Revealing all safe places means victory", () {
    final game = makeGame(rows: 2, columns: 1, numMines: 1);
    final board = game.generateBoardFromMinePositions(<Pos>[Pos(x: 1, y: 0)]);

    expect(game.checkGameStateType(board), GameStateType.playing);

    final revealedBoard = game.revealPlaces(board, Pos(x: 0, y: 0));

    expect(revealedBoard[0].kind, equals(PlaceKind.safe));
    expect(revealedBoard[1].kind, equals(PlaceKind.mine));

    expect(revealedBoard[0].state, equals(PlaceStateType.opened));
    expect(revealedBoard[1].state, equals(PlaceStateType.closed));

    expect(game.checkGameStateType(revealedBoard), GameStateType.victory);
  });

  test("Revealing a mine place means defeat", () {
    final game = makeGame(rows: 2, columns: 1, numMines: 1);
    final board = game.generateBoardFromMinePositions(<Pos>[Pos(x: 1, y: 0)]);

    expect(game.checkGameStateType(board), GameStateType.playing);

    final revealedBoard = game.revealPlaces(board, Pos(x: 1, y: 0));

    expect(revealedBoard[0].kind, equals(PlaceKind.safe));
    expect(revealedBoard[1].kind, equals(PlaceKind.mine));

    expect(revealedBoard[0].state, equals(PlaceStateType.closed));
    expect(revealedBoard[1].state, equals(PlaceStateType.exploded));

    expect(game.checkGameStateType(revealedBoard), GameStateType.defeat);
  });

  test("Flagging a mine should not count as victory nor defeat", () {
    final game = makeGame(rows: 2, columns: 1, numMines: 1);
    final board = game.generateBoardFromMinePositions(<Pos>[Pos(x: 1, y: 0)]);

    expect(game.checkGameStateType(board), GameStateType.playing);

    final flaggedBoard =
        game.togglePlace(board, board[game.positionToIndex(Pos(x: 1, y: 0))]);

    expect(flaggedBoard[0].kind, equals(PlaceKind.safe));
    expect(flaggedBoard[1].kind, equals(PlaceKind.mine));

    expect(flaggedBoard[0].state, equals(PlaceStateType.closed));
    expect(flaggedBoard[1].state, equals(PlaceStateType.flagged));

    expect(game.checkGameStateType(flaggedBoard), GameStateType.playing);
  });

  test("Flagged places cannot be revealed", () {
    final game = makeGame(rows: 1, columns: 1, numMines: 0);
    final boardStart = game.generateBoardFromMinePositions(<Pos>[]);

    final flaggedBoard = game.togglePlace(
        boardStart, boardStart[game.positionToIndex(Pos(x: 0, y: 0))]);

    expect(flaggedBoard[0].state, equals(PlaceStateType.flagged));

    final openedBoard = game.revealPlaces(flaggedBoard, Pos(x: 0, y: 0));

    expect(openedBoard[0].state, equals(PlaceStateType.flagged));
  });
}
