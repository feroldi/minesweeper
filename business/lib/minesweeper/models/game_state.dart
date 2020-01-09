import 'dart:math';
import 'dart:collection';

import 'package:business/minesweeper/models/board_dimensions.dart';
import 'package:business/minesweeper/models/game_options.dart';
import 'package:business/minesweeper/models/game_state_type.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:business/minesweeper/models/pos.dart';

class GameState {
  GameOptions options;

  GameState({this.options});

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

    if (origin.state != PlaceStateType.closed) return board;

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

      if (place.state == PlaceStateType.closed &&
          place.kind != PlaceKind.mine) {
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

  GameStateType checkGameStateType(List<Place> board) {
    final anyTriggeredMine = board.any((place) =>
        place.kind == PlaceKind.mine && isRevealedState(place.state));

    if (anyTriggeredMine) return GameStateType.defeat;

    final remainingClosedPlaces = board.fold(
        0,
        (numClosed, place) =>
            numClosed + (isRevealedState(place.state) ? 0 : 1));

    return remainingClosedPlaces <= options.numMines
        ? GameStateType.victory
        : GameStateType.playing;
  }

  int positionToIndex(Pos pos) => this.options.dimensions.positionToIndex(pos);
  Pos indexToPosition(int index) =>
      this.options.dimensions.indexToPosition(index);
  bool isPosInBounds(Pos pos) => options.dimensions.isPosInBounds(pos);
}
