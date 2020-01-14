import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:business/minesweeper/models/board_options.dart';
import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/minesweeper/models/board_status.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/pos.dart';

class CreateSpectatorBoardAction extends ReduxAction<BoardState> {
  @override
  Future<BoardState> reduce() async {
    final boardRef = Firestore.instance.collection("boards").document();

    await boardRef.setData({
      "rows": state.options.dimensions.rows,
      "columns": state.options.dimensions.columns,
      "mines": state.options.numMines,
      "data": state.board.map((place) => place.toJson()).toList(),
    });

    return state.copyWith(
      boardID: boardRef.documentID,
    );
  }
}
