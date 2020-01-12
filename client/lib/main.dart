import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:client/minesweeper/board_page_CONNECTOR_widget.dart';
import 'package:business/minesweeper/models/board_state.dart';
import 'package:business/minesweeper/models/board_options.dart';
import 'package:business/minesweeper/models/board_dimensions.dart';

Store<BoardState> store;

void main() {
  store = Store<BoardState>(
      initialState: BoardState.generateRandomBoard(
    options: BoardOptions(
      dimensions: BoardDimensions(rows: 10, columns: 10),
      numMines: 10,
    ),
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StoreProvider<BoardState>(
        store: store,
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
          ),
          home: SafeArea(
            child: Scaffold(
              body: BoardPageConnector(),
            ),
          ),
        ),
      );
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: GridView.count(
          crossAxisCount: 5,
          children: List.filled(5 * 8, buildPlaceTile()),
        ),
      ),
    );
  }
}

Container buildPlaceTile({bool isPressed, bool isRevealed}) {
  final lighter = BorderSide(width: 3.0, color: Colors.grey[100]);
  final darker = BorderSide(width: 3.0, color: Colors.grey);
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[350],
      border: Border(
        top: lighter,
        left: lighter,
        bottom: darker,
        right: darker,
      ),
    ),
  );
}
