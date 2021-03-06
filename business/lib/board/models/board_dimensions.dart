import 'dart:math';

import 'package:business/board/models/pos.dart';

/// An index-to-position (and vice-versa) converter.
///
/// The dimensions of the game board are given by [rows] and [columns].
/// Conversion of indices into positions and back are done in a row-major
/// fashion.
class BoardDimensions {
  final int rows;
  final int columns;

  int get length => this.rows * this.columns;

  BoardDimensions({this.rows, this.columns}) : assert(rows > 0 && columns > 0);

  bool isPosInBounds(Pos pos) =>
      pos.x.clamp(0, rows - 1) == pos.x && pos.y.clamp(0, columns - 1) == pos.y;

  bool isIndexInBounds(int index) => index.clamp(0, length - 1) == index;

  int positionToIndex(Pos pos) {
    assert(isPosInBounds(pos));
    return pos.x + pos.y * rows;
  }

  Pos indexToPosition(int index) {
    assert(isIndexInBounds(index));
    return Pos(x: index % rows, y: index ~/ rows);
  }
}
