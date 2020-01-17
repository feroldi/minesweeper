import 'dart:math';

import 'package:business/board/models/board_dimensions.dart';
import 'package:business/board/models/board_options.dart';
import 'package:business/board/models/board_status.dart';
import 'package:business/board/models/place.dart';
import 'package:business/board/models/place_kind.dart';
import 'package:business/board/models/place_state_type.dart';
import 'package:business/board/models/pos.dart';

/// A game board state that holds board configurations and places.
class BoardState {
  /// The game board Firestore document ID, if any.
  String boardID;

  /// The board's dimensions and number of mines.
  BoardOptions options;

  /// The board's data.
  List<Place> board;

  BoardState({
    this.boardID,
    this.options,
    this.board,
  });

  static BoardState initialState() => null;

  BoardState copyWith({
    String boardID,
    BoardOptions options,
    List<Place> board,
  }) =>
      BoardState(
        boardID: boardID ?? this.boardID,
        options: options ?? this.options,
        board: board ?? this.board,
      );

  factory BoardState.fromJson(Map<String, dynamic> snap) => BoardState(
        options: BoardOptions(
            dimensions: BoardDimensions(
              rows: snap["rows"],
              columns: snap["columns"],
            ),
            numMines: snap["mines"]),
        board: List.from(snap["board"])
            .map((datum) => Place.fromJson(datum.cast<String, dynamic>()))
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "rows": options.dimensions.rows,
        "columns": options.dimensions.columns,
        "mines": options.numMines,
        "board": board.map((place) => place.toJson()).toList(),
      };

  int positionToIndex(Pos pos) => options.dimensions.positionToIndex(pos);

  Pos indexToPosition(int index) => options.dimensions.indexToPosition(index);

  bool isPosInBounds(Pos pos) => options.dimensions.isPosInBounds(pos);

  Place placeAt(Pos pos) => board[positionToIndex(pos)];

  /// Creates a board with mines at the positions given by [minePositions].
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

  /// Creates a board with mines put at random positions.
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

  /// Computes the game board's status: playing, victory or defeat.
  BoardStatus checkStatus() {
    final anyTriggeredMine = board.any((place) =>
        place.kind == PlaceKind.mine && isRevealedState(place.state));

    if (anyTriggeredMine) return BoardStatus.defeat;

    // All mines have to be flagged, and there can't be any closed places.
    // We could do better without a linear search algorithm, e.g., storing the
    // flagged and closed places count and updating after toggle/reveal
    // actions. But this is good enough for this project.
    final flaggedMinesCount = board.fold(
        0,
        (numClosed, place) =>
            numClosed +
            (place.state == PlaceStateType.flagged &&
                    place.kind == PlaceKind.mine
                ? 1
                : place.state == PlaceStateType.closed ? -1 : 0));

    return flaggedMinesCount == options.numMines
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
