import 'dart:math';
import 'dart:collection';

import 'package:quiver/core.dart' show hash2;

/// An index-to-position (and vice-versa) converter based on a board's number
/// of [rows] and [columns].
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

/// A set of possible place's states, such as [closed], [exploded] and so on.
enum PlaceState {
  closed,
  opened,
  flagged,
  exploded,
  flagExploded,
}

bool isRevealedState(PlaceState state) {
  return const [PlaceState.opened, PlaceState.exploded, PlaceState.flagExploded].contains(state);
}

/// A set of possible place's kinds, such as [safe] and [mine].
enum PlaceKind {
  safe,
  mine,
}

/// A game state which dictates whether the player is currently playing, has
/// won or has lost the game.
enum GameState {
  playing,
  victory,
  defeat,
}

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

/// A square (or place) in the board which has a [pos] (position) and defines
/// the [kind], [state] and number of adjacent mines ([neighbourMinesCount]) of
/// that place.
class Place {
  final Pos pos;
  final PlaceKind kind;
  final PlaceState state;
  final int neighbourMinesCount;

  Place(
      {this.pos,
      this.kind = PlaceKind.safe,
      this.state = PlaceState.closed,
      this.neighbourMinesCount = 0});

  Place copyWith(
          {Pos pos,
          PlaceKind kind,
          PlaceState state,
          int neighbourMinesCount}) =>
      Place(
        pos: pos ?? this.pos,
        kind: kind ?? this.kind,
        state: state ?? this.state,
        neighbourMinesCount: neighbourMinesCount ?? this.neighbourMinesCount,
      );

  factory Place.asMine(Place place) => place.copyWith(kind: PlaceKind.mine);

  factory Place.open(Place place) {
    final isSafe = place.kind == PlaceKind.safe;
    switch (place.state) {
      case PlaceState.closed:
        return place.copyWith(
            state: isSafe ? PlaceState.opened : PlaceState.exploded);
      case PlaceState.flagged:
        return place.copyWith(
            state: isSafe ? PlaceState.opened : PlaceState.flagExploded);
      default:
        return place;
    }
  }

  factory Place.toggle(Place place) =>
      place.copyWith(state: _nextPlaceState(place.state));
}

PlaceState _nextPlaceState(PlaceState state) {
  switch (state) {
    case PlaceState.closed:
      return PlaceState.flagged;
    case PlaceState.flagged:
      return PlaceState.closed;
    default:
      return state;
  }
}

class GameOptions {
  BoardDimensions dimensions;
  int numMines;

  GameOptions({this.dimensions, this.numMines});
}

class Game {
  GameOptions options;

  Game({this.options});

  List<Place> generateBoardFromMinePositions(List<Pos> minePositions) {
    assert(minePositions.length == options.numMines);
    final board = List<Place>.generate(options.dimensions.length,
        (index) => Place(pos: indexToPosition(index)));
    for (final minePos in minePositions) {
      assert(isPosInBounds(minePos));
      final mineIndex = positionToIndex(minePos);
      board[mineIndex] = Place.asMine(board[mineIndex]);
    }
    return _computeNeighbourMinesCount(board);
  }

  List<Place> generateRandomBoard([Random rand]) {
    final kinds = List<PlaceKind>.generate(options.dimensions.length,
        (index) => index < options.numMines ? PlaceKind.mine : PlaceKind.safe);
    kinds.shuffle(rand);
    final board = List<Place>.generate(options.dimensions.length,
        (index) => Place(pos: indexToPosition(index), kind: kinds[index]));
    return _computeNeighbourMinesCount(board);
  }

  List<Place> _computeNeighbourMinesCount(List<Place> board) {
    return board
        .map((place) => place.copyWith(
            neighbourMinesCount: findPlaceNeighbours(board, place)
                .where((neighbour) => neighbour.kind == PlaceKind.mine)
                .toList()
                .length))
        .toList();
  }

  List<Place> togglePlace(List<Place> board, Place origin) {
    final newBoard = List.of(board);
    final originIndex = positionToIndex(origin.pos);
    newBoard[originIndex] = Place.toggle(newBoard[originIndex]);
    return newBoard;
  }

  List<Place> revealPlaces(List<Place> board, Pos originPos) {
    final origin = board[positionToIndex(originPos)];

    if (origin.state != PlaceState.closed) return board;

    if (origin.kind == PlaceKind.mine) {
      return triggerMinesExplosion(board);
    }

    final queue = Queue<Pos>()..add(origin.pos);
    final visitedPlaces = HashSet<Pos>();
    final revealedPlaces = Map<int, Place>();

    // A BFS in the wild? My bachelor is finally starting to pay off! /s
    while (queue.isNotEmpty) {
      final placePos = queue.removeFirst();
      final place = board[positionToIndex(placePos)];

      if (place.state == PlaceState.closed && place.kind != PlaceKind.mine) {
        revealedPlaces.putIfAbsent(
            positionToIndex(place.pos), () => Place.open(place));

        if (place.neighbourMinesCount == 0) {
          final neighbours = findPlaceNeighbours(board, place)
              .where((neighbour) => !visitedPlaces.contains(neighbour.pos))
              .map((neighbour) => neighbour.pos)
              .toList();

          // Note that we also mark our neighbours as visited places. This is
          // done to filter out already queued neighbours when computing a
          // place's neighbour.
          queue.addAll(neighbours);
          visitedPlaces.addAll(neighbours);
        }
      }
    }

    final newBoard = List<Place>();
    board.asMap().forEach(
        (index, place) => newBoard.add(revealedPlaces[index] ?? place));

    return newBoard;
  }

  Iterable<Place> findPlaceNeighbours(List<Place> board, Place place) sync* {
    for (final i in const [-1, 0, 1]) {
      for (final j in const [-1, 0, 1]) {
        if (i == 0 && j == 0) continue;
        final neighbourPos = Pos(x: place.pos.x + i, y: place.pos.y + j);
        if (isPosInBounds(neighbourPos)) {
          yield board[positionToIndex(neighbourPos)];
        }
      }
    }
  }

  List<Place> triggerMinesExplosion(List<Place> board) {
    return board
        .map(
            (place) => place.kind == PlaceKind.mine ? Place.open(place) : place)
        .toList();
  }

  GameState checkGameState(List<Place> board) {
    final anyTriggeredMine = board.any((place) =>
        place.kind == PlaceKind.mine && isRevealedState(place.state));

    if (anyTriggeredMine) return GameState.defeat;

    final remainingClosedPlaces = board.fold(
        0,
        (numClosed, place) =>
            numClosed + (isRevealedState(place.state) ? 0 : 1));

    return remainingClosedPlaces <= options.numMines
        ? GameState.victory
        : GameState.playing;
  }

  int positionToIndex(Pos pos) => this.options.dimensions.positionToIndex(pos);
  Pos indexToPosition(int index) =>
      this.options.dimensions.indexToPosition(index);
  bool isPosInBounds(Pos pos) => options.dimensions.isPosInBounds(pos);
}
