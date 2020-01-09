/// A set of possible place's states, such as [closed], [exploded] and so on.
enum PlaceStateType {
  closed,
  opened,
  flagged,
  exploded,
  flagExploded,
}

bool isRevealedState(PlaceStateType state) {
  return const [
    PlaceStateType.opened,
    PlaceStateType.exploded,
    PlaceStateType.flagExploded
  ].contains(state);
}
