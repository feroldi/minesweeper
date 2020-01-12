/// A set of possible place's states, such as [closed], [exploded] and so on.
enum PlaceStateType {
  closed,
  opened,
  flagged,
  wronglyFlagged,
  exploded,
}

bool isRevealedState(PlaceStateType state) {
  return const [
    PlaceStateType.opened,
    PlaceStateType.exploded,
    PlaceStateType.wronglyFlagged,
  ].contains(state);
}

bool isUnreleavedState(PlaceStateType state) {
  return const [
    PlaceStateType.closed,
    PlaceStateType.flagged,
  ].contains(state);
}
