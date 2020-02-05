import Foundation

/// Abstraction over session used to communicate with given host.
/// Works as context provided to all request done through it.
/// Might be used to persist data between requests.
/// - warning: SessionBase is not intended to be used directly.
/// Please use NetworkSession, NetworkConnectionSession, NetworkDownloadSession
/// or any other protocol describing specific session type.
public protocol SessionBase {
  /// Base components of URL used by this session and associated requests.
  /// - warning: path component will be replaced by requests
  /// when making acctual network request, please do not specify it manually.
  var urlComponents: URLComponents { get }
}
