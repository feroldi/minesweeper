import 'package:async_redux/async_redux.dart';
import 'package:test/test.dart';

import 'package:business/minesweeper/actions/board_base_action.dart';
import 'package:business/minesweeper/actions/board_command_action.dart';
import 'package:business/minesweeper/actions/create_spectator_board_action.dart';
import 'package:business/minesweeper/actions/reveal_places_action.dart';
import 'package:business/minesweeper/actions/toggle_place_action.dart';
import 'package:business/minesweeper/actions/trigger_mine_explosion_action.dart';
import 'package:business/minesweeper/models/board_dimensions.dart';
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
  test("Do not reveal neighbours when there are mines around", () async {
    final store = Store<BoardState>(
        initialState: makeBoard(
            rows: 2, columns: 2, minePositions: <Pos>[Pos(x: 1, y: 0)]));
    final storeTester = StoreTester.from(store);

    storeTester
        .dispatch(RevealPlacesAction(store.state.placeAt(Pos(x: 0, y: 1))));
    TestInfo<BoardState> info = await storeTester.wait(RevealPlacesAction);

    expect(info.state.board[0].kind, equals(PlaceKind.safe));
    expect(info.state.board[1].kind, equals(PlaceKind.mine));
    expect(info.state.board[2].kind, equals(PlaceKind.safe));
    expect(info.state.board[3].kind, equals(PlaceKind.safe));

    expect(info.state.board[0].state, equals(PlaceStateType.closed));
    expect(info.state.board[1].state, equals(PlaceStateType.closed));
    expect(info.state.board[2].state, equals(PlaceStateType.opened));
    expect(info.state.board[3].state, equals(PlaceStateType.closed));
  });

  test(
      "Reveal neighbours of a place that is not a mine and has zero adjacent mines",
      () async {
    final store = Store<BoardState>(
        initialState: makeBoard(
            rows: 3, columns: 3, minePositions: <Pos>[Pos(x: 2, y: 0)]));
    final storeTester = StoreTester.from(store);

    storeTester
        .dispatch(RevealPlacesAction(store.state.placeAt(Pos(x: 0, y: 2))));
    TestInfo<BoardState> info = await storeTester.wait(RevealPlacesAction);

    expect(info.state.board[0].kind, equals(PlaceKind.safe));
    expect(info.state.board[1].kind, equals(PlaceKind.safe));
    expect(info.state.board[2].kind, equals(PlaceKind.mine));
    expect(info.state.board[3].kind, equals(PlaceKind.safe));
    expect(info.state.board[4].kind, equals(PlaceKind.safe));
    expect(info.state.board[5].kind, equals(PlaceKind.safe));
    expect(info.state.board[6].kind, equals(PlaceKind.safe));
    expect(info.state.board[7].kind, equals(PlaceKind.safe));
    expect(info.state.board[8].kind, equals(PlaceKind.safe));

    expect(info.state.board[0].state, equals(PlaceStateType.opened));
    expect(info.state.board[1].state, equals(PlaceStateType.opened));
    expect(info.state.board[2].state, equals(PlaceStateType.closed));
    expect(info.state.board[3].state, equals(PlaceStateType.opened));
    expect(info.state.board[4].state, equals(PlaceStateType.opened));
    expect(info.state.board[5].state, equals(PlaceStateType.opened));
    expect(info.state.board[6].state, equals(PlaceStateType.opened));
    expect(info.state.board[7].state, equals(PlaceStateType.opened));
    expect(info.state.board[8].state, equals(PlaceStateType.opened));
  });

  test("Opening a mine triggers all other mines to explode", () async {
    final store = Store<BoardState>(
        initialState: makeBoard(
            rows: 3,
            columns: 1,
            minePositions: <Pos>[Pos(x: 1, y: 0), Pos(x: 2, y: 0)]));
    final storeTester = StoreTester.from(store);

    storeTester
        .dispatch(RevealPlacesAction(store.state.placeAt(Pos(x: 1, y: 0))));
    TestInfo<BoardState> info = await storeTester
        .waitAllGetLast([RevealPlacesAction, TriggerMineExplosionAction]);

    expect(info.state.board[0].kind, equals(PlaceKind.safe));
    expect(info.state.board[1].kind, equals(PlaceKind.mine));
    expect(info.state.board[2].kind, equals(PlaceKind.mine));

    expect(info.state.board[0].state, equals(PlaceStateType.closed));
    expect(info.state.board[1].state, equals(PlaceStateType.exploded));
    expect(info.state.board[2].state, equals(PlaceStateType.exploded));
  });

  test("Toggling a place marks it as flagged and closed back and forth",
      () async {
    // FIXME: It is weird that it's possible to create boards without any mines
    // in it.
    final store = Store<BoardState>(
        initialState: makeBoard(rows: 2, columns: 1, minePositions: <Pos>[]));
    final storeTester = StoreTester.from(store);

    storeTester
        .dispatch(TogglePlaceAction(store.state.placeAt(Pos(x: 0, y: 0))));

    storeTester
        .dispatch(TogglePlaceAction(store.state.placeAt(Pos(x: 0, y: 0))));

    TestInfoList<BoardState> infos =
        await storeTester.waitAll([TogglePlaceAction, TogglePlaceAction]);

    expect(infos.get(TogglePlaceAction, 1).state.board[0].state,
        equals(PlaceStateType.flagged));
    expect(infos.get(TogglePlaceAction, 2).state.board[0].state,
        equals(PlaceStateType.closed));
  });

  test("Places other than closed and flagged cannot be toggled", () async {
    final store = Store<BoardState>(
        initialState: makeBoard(rows: 1, columns: 1, minePositions: <Pos>[]));
    final storeTester = StoreTester.from(store);

    storeTester
        .dispatch(RevealPlacesAction(store.state.placeAt(Pos(x: 0, y: 0))));

    storeTester
        .dispatch(TogglePlaceAction(store.state.placeAt(Pos(x: 0, y: 0))));

    TestInfo<BoardState> info = await storeTester
        .waitAllGetLast([RevealPlacesAction, TogglePlaceAction]);

    expect(info.state.board[0].state, equals(PlaceStateType.opened));
  });

  test("A flagged safe place should be stated as wrong after defeat", () async {
    final store = Store<BoardState>(
        initialState: makeBoard(
            rows: 3,
            columns: 1,
            minePositions: <Pos>[Pos(x: 1, y: 0), Pos(x: 2, y: 0)]));
    final storeTester = StoreTester.from(store);

    storeTester
        .dispatch(TogglePlaceAction(store.state.placeAt(Pos(x: 0, y: 0))));

    storeTester
        .dispatch(TogglePlaceAction(store.state.placeAt(Pos(x: 1, y: 0))));

    storeTester
        .dispatch(RevealPlacesAction(store.state.placeAt(Pos(x: 2, y: 0))));

    TestInfo<BoardState> info = await storeTester.waitAllGetLast([
      TogglePlaceAction,
      TogglePlaceAction,
      RevealPlacesAction,
      TriggerMineExplosionAction
    ]);

    expect(info.state.board[0].kind, equals(PlaceKind.safe));
    expect(info.state.board[1].kind, equals(PlaceKind.mine));
    expect(info.state.board[2].kind, equals(PlaceKind.mine));

    expect(info.state.board[0].state, equals(PlaceStateType.wronglyFlagged));
    expect(info.state.board[1].state, equals(PlaceStateType.flagged));
    expect(info.state.board[2].state, equals(PlaceStateType.exploded));
  });

  test("Revealing all safe places and flagging all mines mean victory",
      () async {
    final store = Store<BoardState>(
        initialState: makeBoard(
            rows: 3, columns: 1, minePositions: <Pos>[Pos(x: 2, y: 0)]));
    final storeTester = StoreTester.from(store);

    expect(store.state.checkStatus(), equals(BoardStatus.playing));

    storeTester
        .dispatch(RevealPlacesAction(store.state.placeAt(Pos(x: 0, y: 0))));

    storeTester
        .dispatch(TogglePlaceAction(store.state.placeAt(Pos(x: 2, y: 0))));

    TestInfoList<BoardState> infos =
        await storeTester.waitAll([RevealPlacesAction, TogglePlaceAction]);

    expect(infos.get(RevealPlacesAction).state.board[0].kind,
        equals(PlaceKind.safe));
    expect(infos.get(RevealPlacesAction).state.board[1].kind,
        equals(PlaceKind.safe));
    expect(infos.get(RevealPlacesAction).state.board[2].kind,
        equals(PlaceKind.mine));

    expect(infos.get(RevealPlacesAction).state.board[0].state,
        equals(PlaceStateType.opened));
    expect(infos.get(RevealPlacesAction).state.board[1].state,
        equals(PlaceStateType.opened));
    expect(infos.get(RevealPlacesAction).state.board[2].state,
        equals(PlaceStateType.closed));

    expect(infos.get(RevealPlacesAction).state.checkStatus(),
        equals(BoardStatus.playing));

    expect(infos.get(TogglePlaceAction).state.board[0].kind,
        equals(PlaceKind.safe));
    expect(infos.get(TogglePlaceAction).state.board[1].kind,
        equals(PlaceKind.safe));
    expect(infos.get(TogglePlaceAction).state.board[2].kind,
        equals(PlaceKind.mine));

    expect(infos.get(TogglePlaceAction).state.board[0].state,
        equals(PlaceStateType.opened));
    expect(infos.get(TogglePlaceAction).state.board[1].state,
        equals(PlaceStateType.opened));
    expect(infos.get(TogglePlaceAction).state.board[2].state,
        equals(PlaceStateType.flagged));

    expect(infos.get(TogglePlaceAction).state.checkStatus(),
        equals(BoardStatus.victory));
  });

  test("Revealing a mine place means defeat", () async {
    final store = Store<BoardState>(
        initialState: makeBoard(
            rows: 3, columns: 1, minePositions: <Pos>[Pos(x: 2, y: 0)]));
    final storeTester = StoreTester.from(store);

    expect(store.state.checkStatus(), equals(BoardStatus.playing));

    storeTester
        .dispatch(RevealPlacesAction(store.state.placeAt(Pos(x: 2, y: 0))));

    TestInfo<BoardState> info = await storeTester
        .waitAllGetLast([RevealPlacesAction, TriggerMineExplosionAction]);

    expect(info.state.board[0].kind, equals(PlaceKind.safe));
    expect(info.state.board[1].kind, equals(PlaceKind.safe));
    expect(info.state.board[2].kind, equals(PlaceKind.mine));

    expect(info.state.board[0].state, equals(PlaceStateType.closed));
    expect(info.state.board[1].state, equals(PlaceStateType.closed));
    expect(info.state.board[2].state, equals(PlaceStateType.exploded));

    expect(info.state.checkStatus(), equals(BoardStatus.defeat));
  });

  test("Flagging a mine should not count as victory nor defeat", () async {
    final store = Store<BoardState>(
        initialState: makeBoard(
            rows: 2, columns: 1, minePositions: <Pos>[Pos(x: 1, y: 0)]));
    final storeTester = StoreTester.from(store);

    expect(store.state.checkStatus(), equals(BoardStatus.playing));

    storeTester
        .dispatch(TogglePlaceAction(store.state.placeAt(Pos(x: 1, y: 0))));

    TestInfo<BoardState> info = await storeTester.wait(TogglePlaceAction);

    expect(info.state.board[0].kind, equals(PlaceKind.safe));
    expect(info.state.board[1].kind, equals(PlaceKind.mine));

    expect(info.state.board[0].state, equals(PlaceStateType.closed));
    expect(info.state.board[1].state, equals(PlaceStateType.flagged));

    expect(info.state.checkStatus(), equals(BoardStatus.playing));
  });

  test("Flagged places cannot be revealed", () async {
    final store = Store<BoardState>(
      initialState: makeBoard(rows: 1, columns: 1, minePositions: <Pos>[]),
    );
    final storeTester = StoreTester.from(store);

    storeTester
        .dispatch(TogglePlaceAction(store.state.placeAt(Pos(x: 0, y: 0))));

    storeTester
        .dispatch(RevealPlacesAction(store.state.placeAt(Pos(x: 0, y: 0))));

    TestInfoList<BoardState> infos =
        await storeTester.waitAll([TogglePlaceAction, RevealPlacesAction]);

    expect(infos.get(TogglePlaceAction).state.board[0].state,
        equals(PlaceStateType.flagged));
    expect(infos.get(RevealPlacesAction).state.board[0].state,
        equals(PlaceStateType.flagged));
  });
}
