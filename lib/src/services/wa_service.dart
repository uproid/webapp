/// Represents a basic service in the application.
/// The [WaService] class is a base class for services that provide various functionalities
/// in the application. It includes a method for generating a string representation of
/// the service.
class WaService {
  /// Returns a string representation of the [WaService] instance.
  ///
  /// This method provides a default string representation indicating the type of the service.
  /// It overrides the [Object.toString] method to return a custom description of the service.
  ///
  /// Returns a [String] representing the type of the service.
  @override
  String toString() {
    return "WaService type";
  }
}
