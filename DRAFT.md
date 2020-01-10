# Flutter challenge: streamable minesweeper

## Requirements

1. 5x10 grid
2. Use `async_redux` lib
3. States: playing, victory, defeat.
4. User may generate a streaming link so others can watch their game

Q: Should the player be able to set mine spawn amount?

## Design

### Grid data structure

Could use a bitset to represent a grid, where 0 is closed and 1 is open (revealed).
The fact that a bitset is unidimensional isn't an issue; the game API should abstract it away and offer functions that work with two-dimensional coordinates.

Q: How to represent other cell states?
A bitset can only communicate closed/open cells, but how does one communicate exploded cells, flagged cells and mine counter?
Well, the counter is easy: it is computed at request (e.g. `cellCountNeighMines(x, y)`).
Furthermore, a state states (pun intended) which actions are possible for a cell.
E.g.,

* If closed, it is openable
* If open or exploded, no action is possible
* If flagged, it is unflaggable (changes to closed)

So there are three actions in total: open, flag, and unflag.

Therefore, a bitset is not possible if we want to keep the data structure simple.
Use a list of states then? Something in the lines of `List<CellState>` for:

    enum CellState {
        closed,
        open,
        flagged,
        exploded,
    }

We won't ever add or remove cells from the grid, so I think a list is good enough.

Eduardo said that all the logic and states should be handled in terms of reducers.
That is, no game logic abstraction is allowed.
But that doesn't mean I can't do the abstraction inside an `AppState`.
So there's that :)

Also, we still need to represent bomb locations.
Do we do it separately?
E.g., a `List` for bomb locations and another for cell statuses?
Shouldn't it be just like a `Cell` then?
A `Cell` describes itself as a safe tile or one that contains a bomb, and additionally its status?
This sounds great:

    class Cell {
        CellState state;
        CellKind kind;
    }

    enum CellKind {
        Safe,
        Bomb,
    }

Alright.

I need an AppState that has:

* Board
* Rows
* Columns
* Is playing?
* Game status (playing, victory, defeat)

These are the states that only exist when playing:

* Board
* Rows
* Columns
* Game status

And these are the ones when not playing:

* Is playing?

### Fill a grid with mines

In order to fill a grid with mines, do not use a "randomly-selects-cells" algorithm.
This algorithm doens't have a fixed point (i.e., not guaranteed to halt), because it looks for vacant cells, but when it selects an occupied one, it just ignores it and tries to select another one.
In practice, it is likely to halt, but it's slow for big grids nonetheless (although not a requirement here).

A good approach is the following: fill the first N grid cells with mines, then `shuffle(grid)`.
This way, the algorithm is linear (fast) and is guaranteed to halt.
However, this does not allow for mine spawn probability.
Q: Should it have a mine spawn probability?

### Commands

As we'll stream a game, we need an instruction set for the game.
There are three possible actions a player can take:

1. Open cell
2. Flag cell
3. Unflag cell

The three of them need a parameter: the cell index.
So, streaming needs only to communicate these three simple commands (i.e., messages) to firebase.

Q: Is is possible to start streaming after a few actions have been taken already?
If so, then we also should send the grid state to the listener.

States like playing, victory and defeat do not need to be communicated.
The game can figure these out from the current grid state.
