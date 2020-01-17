/// A set of possible place's kinds, such as [safe] and [mine].
///
/// A [safe] place reveals itself as an empty square, whereas a [mine] place
/// triggers an explosion when it gets revealed, meaning a game defeat.
enum PlaceKind {
  safe,
  mine,
}
