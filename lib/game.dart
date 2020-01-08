enum CellKind {
  safe,
  mine,
}

enum CellState {
  closed,
  open,
  flagged,
}

class Cell {
  CellKind kind;
  CellState state;

  Cell({this.kind, this.state}) : assert(kind != null && state != null);

  String toString() {
    return '(${this.kind}, ${this.state})';
  }
}

class Grid {
  final int width;
  final int height;
  final int mineCount; //< Number of mines in the grid.

  // FIXME: This shouldn't be public, but how else could we initialize a Grid
  // by passing cells?
  final List<Cell> cells;

  Grid(this.width, this.height, {this.mineCount, this.cells});

  static Grid generate(int width, int height, {int mineCount}) {
    // Fills the first `mineCount` grid cells with mines, and the rest with
    // safe cells. Then it shuffles the array to get a nice mine distribution.
    final cells = List<Cell>.generate(
        width * height,
        (index) => Cell(kind: index < mineCount ? CellKind.mine : CellKind.safe,
            state: CellState.closed));

    cells.shuffle();

    return Grid(width, height, mineCount: mineCount, cells: cells);
  }

  Cell cellAt(int x, int y) {
    return this.cells[x * width + y];
  }
}

class CellVisitor<T> {
  Grid grid;
  final Set<int> visited = Set();
  int x;
  int y;

  CellVisitor(this.grid, this.x, this.y);

  void start() {
    this.walk(this.x, this.y);
  }

  void visit(Cell cell) {
  }

  bool shouldVisit(int x, int y) {
    return true;
  }

  bool _isInBounds(int x, int y) {
    return x.clamp(0, this.grid.width - 1) == x && y.clamp(0, this.grid.height - 1) == y;
  }

  void walk(int x, int y) {
    for (final i in const [-1, 0, 1]) {
      for (final j in const [-1, 0, 1]) {
        final nx = x + i;
        final ny = y + j;
        final cellIndex = nx * this.grid.width + ny;
        if (this._isInBounds(nx, ny)
            && !this.visited.contains(cellIndex) && this.shouldVisit(nx, ny)) {
          visit(this.grid.cellAt(nx, ny));
          this.visited.add(cellIndex);
          walk(nx, ny);
        }
      }
    }
  }
}

class CountMines extends CellVisitor<int> {
  int counter = 0;

  CountMines(Grid grid, int x, int y) : super(grid, x, y);

  @override
  void visit(Cell cell) {
    if (cell.kind == CellKind.mine)
      this.counter += 1;
  }

  @override
  bool shouldVisit(int x, int y) {
    final d = (this.x - x).abs() + (this.y - y).abs();
    return d > 0 && d <= 2;
  }
}
