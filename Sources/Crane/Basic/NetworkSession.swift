import Foundation

/// Abstraction over network session, used to communicate with given host.
/// Works as context provided to all request done through it.
/// Might be used to persist data between requests.
/// Intended to use with NetworkRequest instances.
public protocol NetworkSession: SessionBase {
  /// Executes given request expecting network response according to
  /// request description in context of this session.
  /// - parameter request: network request to make
  /// - parameter callback: function called when result of request is available
  func make<Request: NetworkRequest>(
    _ request: Request,
    _ callback: @escaping ResultCallback<Request.Response, NetworkError>
  ) where Request.Session == Self
}
