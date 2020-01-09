/// A set of possible place's states, such as [closed], [exploded] and so on.
enum PlaceState {
  closed,
  opened,
  flagged,
  exploded,
  flagExploded,
}

bool isRevealedState(PlaceState state) {
  return const [PlaceState.opened, PlaceState.exploded, PlaceState.flagExploded]
      .contains(state);
}
