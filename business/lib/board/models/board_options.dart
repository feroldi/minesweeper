import 'package:business/board/models/board_dimensions.dart';

/// Options for a game board.
///
/// A game board is specified by its [dimensions] (i.e., how big it goes
/// horizontally and vertically) and the number of hidden mines given by
/// [numMines].
class BoardOptions {
  BoardDimensions dimensions;
  int numMines;

  BoardOptions({this.dimensions, this.numMines});
}
