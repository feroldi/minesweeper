import 'package:business/minesweeper/models/board_dimensions.dart';

class GameOptions {
  BoardDimensions dimensions;
  int numMines;

  GameOptions({this.dimensions, this.numMines});
}
