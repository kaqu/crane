import Foundation

/// Abstraction over network session, used to communicate with given host.
/// Works as context provided to all request done through it.
/// Might be used to persist data between requests.
public protocol NetworkSession {
  /// Base components of URL used by this session and associated requests.
  /// - warning: path component will be replaced by requests
  /// when making acctual network request, please do not specify it manually.
  var urlComponents: URLComponents { get }
  /// Executes given request expecting network response according to
  /// request description in context of this session.
  /// - parameter request: network request to make
  /// - parameter callback: function called when result of request is available
  func make<Request: NetworkRequest>(
    _ request: Request,
    _ callback: @escaping ResultCallback<Request.Response, NetworkError>
  ) where Request.Session == Self
}
