import 'package:quiver/core.dart' show hash2;

/// A coordinate into the game board.
///
/// The game board's origin coordinate starts at the leftmost, topmost square.
/// The [x] value represents a column position, and the [y] value represents a
/// row position from top down.
class Pos {
  final int x;
  final int y;

  Pos({this.x, this.y});

  String toString() => '($x, $y)';

  factory Pos.fromJson(Map<String, dynamic> json) => Pos(
        x: json["x"],
        y: json["y"],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "x": x,
        "y": y,
      };

  bool operator ==(Object o) =>
      o is Pos && o.runtimeType == runtimeType && o.x == x && o.y == y;

  int get hashCode => hash2(x.hashCode, y.hashCode);
}
