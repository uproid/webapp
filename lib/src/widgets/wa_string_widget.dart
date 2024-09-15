/// An abstract class representing a basic widget that provides an HTML layout as a string.
///
/// The [WaStringWidget] class serves as a base class for widgets that involve
/// generating or managing HTML content in string format. It defines a single
/// layout property that can be used by subclasses to provide a default or
/// customizable HTML structure.
abstract class WaStringWidget {
  /// The default HTML layout used by this widget.
  ///
  /// This layout is represented as a string and is intended to be extended
  /// or overridden by subclasses to provide custom HTML content.
  final String layout = '<html></html>';
}
