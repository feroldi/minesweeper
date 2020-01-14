import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/minesweeper/models/board_status.dart';
import 'package:business/minesweeper/models/place.dart';
import 'package:business/minesweeper/models/place_kind.dart';
import 'package:business/minesweeper/models/place_state_type.dart';
import 'package:client/minesweeper/board_page_CONNECTOR_widget.dart';

// TODO: There are a bit of replicated functionalities here, such as
// minesweeper-like box decorating. It's working right now, but it'd be a good
// call to refactor these parts out into helper functions.

// FIXME: Some buttons, text etc aren't responsible to screen size changes.

class BoardPage extends StatelessWidget {
  final int rows;
  final int columns;
  final int totalMines;
  final List<Place> boardData;
  final BoardStatus gameplayStatus;
  final String streamingBoardID;
  final Function(Place place) onTileTap;
  final Function(Place place) onTilePress;
  final VoidCallback onPlayerReactionButtonTap;
  final VoidCallback onCreateSpectatorBoard;

  BoardPage({
    Key key,
    @required this.rows,
    @required this.columns,
    @required this.totalMines,
    @required this.boardData,
    @required this.gameplayStatus,
    @required this.streamingBoardID,
    @required this.onTileTap,
    @required this.onTilePress,
    @required this.onPlayerReactionButtonTap,
    @required this.onCreateSpectatorBoard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final board = GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: rows,
      ),
      itemBuilder: (context, index) => buildPlaceTile(
          place: boardData[index],
          iconSize: 138.0 / rows,
          onTileTap: onTileTap,
          onTilePress: onTilePress),
      itemCount: rows * columns,
    );

    return Container(
      color: Colors.grey[350],
      child: Padding(
        padding: EdgeInsets.all(mediaSize.width * 0.05),
        child: Column(
          children: <Widget>[
            buildBoardHeader(
              gameplayStatus: gameplayStatus,
              onPlayerReactionButtonTap: onPlayerReactionButtonTap,
              onCreateSpectatorBoard: onCreateSpectatorBoard,
            ),
            SizedBox(height: 12.0),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 3.0, color: Colors.grey),
                    left: BorderSide(width: 3.0, color: Colors.grey),
                    bottom: BorderSide(width: 3.0, color: Colors.grey[100]),
                    right: BorderSide(width: 3.0, color: Colors.grey[100]),
                  ),
                ),
                child: board,
              ),
            ),
            SizedBox(height: 12.0),
            Container(
              height: 48.0,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 3.0, color: Colors.grey),
                  left: BorderSide(width: 3.0, color: Colors.grey),
                  bottom: BorderSide(width: 3.0, color: Colors.grey[100]),
                  right: BorderSide(width: 3.0, color: Colors.grey[100]),
                ),
              ),
              child: Center(child: SelectableText(streamingBoardID ?? "")),
            ),
          ],
        ),
      ),
    );
  }
}

Container buildBoardHeader({
  BoardStatus gameplayStatus,
  VoidCallback onPlayerReactionButtonTap,
  VoidCallback onCreateSpectatorBoard,
}) {
  return Container(
    height: 48.0,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(width: 3.0, color: Colors.grey),
        left: BorderSide(width: 3.0, color: Colors.grey),
        bottom: BorderSide(width: 3.0, color: Colors.grey[100]),
        right: BorderSide(width: 3.0, color: Colors.grey[100]),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        buildPlayerReactionButton(
            gameplayStatus: gameplayStatus,
            onPlayerReactionButtonTap: onPlayerReactionButtonTap),
        buildCreateSpectatorBoardButton(
            onCreateSpectatorBoard: onCreateSpectatorBoard),
      ],
    ),
  );
}

GestureDetector buildPlayerReactionButton({
  BoardStatus gameplayStatus,
  VoidCallback onPlayerReactionButtonTap,
}) {
  final playerReaction = Container(
    width: 46.0,
    height: 46.0,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(width: 5.0, color: Colors.grey[100]),
        left: BorderSide(width: 5.0, color: Colors.grey[100]),
        bottom: BorderSide(width: 5.0, color: Colors.grey),
        right: BorderSide(width: 5.0, color: Colors.grey),
      ),
    ),
    child: Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(3.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow,
            ),
          ),
        ),
        Icon(
          gameplayStatus == BoardStatus.playing
              ? Icons.sentiment_satisfied
              : gameplayStatus == BoardStatus.victory
                  ? Icons.sentiment_very_satisfied
                  : Icons.sentiment_very_dissatisfied,
          color: Colors.black,
          size: 32.0,
        ),
      ],
    ),
  );

  return GestureDetector(
    onTap: onPlayerReactionButtonTap,
    child: playerReaction,
  );
}

GestureDetector buildCreateSpectatorBoardButton({
  VoidCallback onCreateSpectatorBoard,
}) {
  final shareButton = Container(
    width: 46.0,
    height: 46.0,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(width: 5.0, color: Colors.grey[100]),
        left: BorderSide(width: 5.0, color: Colors.grey[100]),
        bottom: BorderSide(width: 5.0, color: Colors.grey),
        right: BorderSide(width: 5.0, color: Colors.grey),
      ),
    ),
    child: Icon(Icons.share, size: 32.0),
  );

  return GestureDetector(
    onTap: onCreateSpectatorBoard,
    child: shareButton,
  );
}

GestureDetector buildPlaceTile(
    {Place place,
    double iconSize,
    Function(Place place) onTileTap,
    Function(Place place) onTilePress}) {
  final isPlaceRevealed = isRevealedState(place.state);
  final lighter = BorderSide(width: 3.0, color: Colors.grey[100]);
  final darker =
      BorderSide(width: isPlaceRevealed ? 1.0 : 3.0, color: Colors.grey);

  final bgColor = isPlaceRevealed ? Colors.grey[200] : Colors.grey[350];
  final topLeftColor = isPlaceRevealed ? darker : lighter;
  final bottomRightColor = darker;

  final mineCounterColor = [
    Colors.blue[600],
    Colors.green[600],
    Colors.red[600],
    Colors.blue[900],
    Colors.green[900],
    Colors.red[900],
    Colors.black,
    Colors.grey,
  ];

  final tileContent = () {
    switch (place.state) {
      case PlaceStateType.closed:
        return null;
      case PlaceStateType.flagged:
        return Text("🚩",
            style: TextStyle(
              color: Colors.red,
              fontSize: iconSize,
            ));
      case PlaceStateType.wronglyFlagged:
        return Text("❌", style: TextStyle(fontSize: iconSize));
      case PlaceStateType.opened:
        if (place.neighbourMinesCount > 0) {
          final minesCount = place.neighbourMinesCount;
          return Text("$minesCount",
              style: TextStyle(
                color: mineCounterColor[minesCount - 1],
                fontWeight: FontWeight.bold,
                fontSize: iconSize,
              ));
        }
        return null;
      case PlaceStateType.exploded:
        return Text("💣", style: TextStyle(fontSize: iconSize));
    }
  };

  final tileContainer = Container(
    decoration: BoxDecoration(
      color: bgColor,
      border: Border(
        top: topLeftColor,
        left: topLeftColor,
        bottom: bottomRightColor,
        right: bottomRightColor,
      ),
    ),
    child: Center(child: tileContent()),
  );

  return GestureDetector(
    onTap: () => onTileTap(place),
    onLongPress: () => onTilePress(place),
    child: tileContainer,
  );
}
