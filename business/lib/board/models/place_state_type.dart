/// A set of possible place's states, such as [closed], [exploded] and so on.
///
/// Places have a few possible states. States such as [closed] and [flagged]
/// indicate an unrevealed square. Other states such as [opened],
/// [wronglyFlagged] and [exploded] mean that a square has been revealed. In
/// the case of safe places, they can be either [opened] or [wronglyFlagged],
/// whereas mine places may only be [exploded].
enum PlaceStateType {
  closed,
  opened,
  flagged,
  wronglyFlagged,
  exploded,
}

/// Checks if [state] indicates a revealed square.
bool isRevealedState(PlaceStateType state) {
  return const [
    PlaceStateType.opened,
    PlaceStateType.exploded,
    PlaceStateType.wronglyFlagged,
  ].contains(state);
}

/// Checks if [state] indicates a unrevealed square.
bool isUnreleavedState(PlaceStateType state) {
  return const [
    PlaceStateType.closed,
    PlaceStateType.flagged,
  ].contains(state);
}
