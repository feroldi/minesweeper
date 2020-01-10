import 'package:async_redux/async_redux.dart';
import 'package:test/test.dart';

import 'package:business/minesweeper/actions/play_new_game_action.dart';
import 'package:business/minesweeper/models/game_state.dart';

void main() {
  test("Creating a new game returns a new game state", () async {
    final storeTester = StoreTester(initialState: GameState.initialState());

    expect(storeTester.state.boardRows, equals(1));
    expect(storeTester.state.boardColumns, equals(1));
    expect(storeTester.state.boardLength, equals(1));
    expect(storeTester.state.totalMines, equals(0));
    expect(storeTester.state.board, isEmpty);
    expect(storeTester.state.isPlaying, isFalse);

    storeTester.dispatch(PlayNewGameAction(rows: 5, columns: 10, mines: 20));
    TestInfo<GameState> info = await storeTester.wait(PlayNewGameAction);

    expect(info.state.boardRows, equals(5));
    expect(info.state.boardColumns, equals(10));
    expect(info.state.boardLength, equals(50));
    expect(info.state.totalMines, equals(20));
    expect(storeTester.state.board, hasLength(50));
    expect(storeTester.state.isPlaying, isTrue);
  });
}
