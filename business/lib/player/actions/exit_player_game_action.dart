import 'package:async_redux/async_redux.dart';

import 'package:business/app/actions/app_base_action.dart';
import 'package:business/app/models/app_state.dart';
import 'package:business/board/models/board_state.dart';

class ExitPlayerGameAction extends AppBaseAction {
  @override
  AppState reduce() {
    return state.copyWith(
      boardState: BoardState.initialState(),
    );
  }

  @override
  void after() => dispatch(NavigateAction<AppState>.pushReplacementNamed('/'));
}
