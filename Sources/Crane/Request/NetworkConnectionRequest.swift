/// Request expecting connection with server allowing sending/receiving data..
public protocol NetworkConnectionRequest: Request where Session: NetworkConnectionSession, Body == Void {
  // MARK: - Type specification
  /// Connection type associated and expected for this request
  typealias Connection = NetworkConnection<Self>
  // MARK: - Configuration
  /// Automatic connection ping interval in seconds.
  /// Ping will not be executed if set to nil.
  static var pingInterval: Int? { get }
}

extension NetworkConnectionRequest {
  static var pingInterval: Int? { nil }
}
