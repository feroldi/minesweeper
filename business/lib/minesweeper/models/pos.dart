import 'package:quiver/core.dart' show hash2;

/// A coordinate in the game board, where [x] is the position (column) in the
/// [y] row from top down.
class Pos {
  final int x;
  final int y;

  Pos({this.x, this.y});

  String toString() => '($x, $y)';

  bool operator ==(Object pos) => pos is Pos && pos.x == x && pos.y == y;

  int get hashCode => hash2(x.hashCode, y.hashCode);
}
