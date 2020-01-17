import 'package:business/board/models/board_state.dart';

class AppState {
  BoardState boardState;

  AppState({this.boardState});

  static AppState initialState() =>
      AppState(boardState: BoardState.initialState());

  AppState copyWith({BoardState boardState}) =>
      AppState(boardState: boardState ?? this.boardState);
}
