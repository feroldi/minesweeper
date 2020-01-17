import 'package:async_redux/async_redux.dart';

import 'package:business/board/models/board_state.dart';

class AppState {
  BoardState boardState;
  Event<String> gameStartedStreamingEvt;

  AppState({this.boardState, this.gameStartedStreamingEvt});

  static AppState initialState() => AppState(
      boardState: BoardState.initialState(),
      gameStartedStreamingEvt: Event<String>.spent());

  AppState copyWith({
    BoardState boardState,
    Event<String> gameStartedStreamingEvt,
  }) =>
      AppState(
        boardState: boardState ?? this.boardState,
        gameStartedStreamingEvt:
            gameStartedStreamingEvt ?? this.gameStartedStreamingEvt,
      );
}
