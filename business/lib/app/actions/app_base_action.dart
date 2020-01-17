import 'package:async_redux/async_redux.dart';

import 'package:business/app/models/app_state.dart';
import 'package:business/board/models/board_state.dart';

abstract class AppBaseAction extends ReduxAction<AppState> {
  BoardState get boardState => state.boardState;
}
