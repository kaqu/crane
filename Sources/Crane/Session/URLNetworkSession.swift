import Foundation
import CraneHTTP
import CraneURL
import Foundation.NSLock

/// Minimal NetworkSession implementation using Foundation.URLSession.
public final class URLNetworkSession {
  
  public let urlBase: URLComponents
  private let urlSession: URLSession
  
  /// - parameter scheme: scheme used to make requests with this session,
  /// dafault is https
  /// - parameter host: host name or ip used to make requests with this session
  /// - parameter port: port used to make requests with this session,
  /// defailt is nil
  /// - parameter urlSession: urlSession instance executing requests,
  /// default is ephemeral session instance
  public init(
    scheme: String = "https",
    host: String,
    port: Int? = nil,
    urlSession: URLSession = .init(configuration: .ephemeral)
  ) {
    self.urlBase = URLComponents(scheme: scheme, host: host, port: port)
    self.urlSession = urlSession
  }
}

extension URLNetworkSession: NetworkSession {

  @discardableResult
  public func make(
    request: HTTPRequest,
    withTimeout timeout: TimeInterval,
    callback: @escaping ResultCallback<HTTPResponse, NetworkError>
  ) -> CancelationToken {
    var foundationRequest: URLRequest = request as URLRequest // TODO: to decide in HTTPRequest.swift
    foundationRequest.timeoutInterval = timeout
    let condLock: NSConditionLock = .init(condition: 0)
    let task = urlSession.dataTask(with: foundationRequest) { data, response, error in
      guard condLock.tryLock(whenCondition: 0) else { return callback(.failure(NetworkError.canceled)) }
      if let error = error as NSError? {
        guard error.domain == NSURLErrorDomain else {
          return callback(.failure(NetworkError.other(error)))
        }
        switch error.code {
        case NSURLErrorCancelled:
          callback(.failure(NetworkError.canceled))
        case NSURLErrorNotConnectedToInternet:
          callback(.failure(NetworkError.noInternet))
        case NSURLErrorTimedOut:
          callback(.failure(NetworkError.timeout))
        case _:
          callback(.failure(NetworkError.other(error)))
        }
      } else if let response = response as? HTTPURLResponse {
        callback(
          .success(
            HTTPResponse(
              url: response.url ?? request.url!, // TODO: force unwrap?
              statusCode: HTTPStatusCode(rawValue: response.statusCode) ?? .custom(response.statusCode),
              headers: HTTPHeaders(response.allHeaderFields as! Dictionary<String, String>), // TODO: FIXME:!!!
              body: data ?? .init()
            )
          )
        )
      } else {
        callback(.failure(NetworkError.internalInconsistency))
      }
    }
    task.resume()
    return CancelationToken {
      guard condLock.try() else { return }
      task.cancel()
      condLock.unlock(withCondition: 1)
    }
  }
}
