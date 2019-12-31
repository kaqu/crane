/// Structured url parameter.
public struct URLParameter {
  /// Name of parameter.
  public let name: String
  /// Value of parameter.
  public let value: String
  /// - parameter name: Name of parameter.
  /// - parameter value: Value of parameter.
  public init(_ name: String, value: String) {
    self.name = name
    self.value = value
  }
}
