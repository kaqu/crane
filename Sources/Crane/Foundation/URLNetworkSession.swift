import Foundation

/// Minimal NetworkSession implementation using Foundation.URLSession
public final class URLNetworkSession: NetworkSession {

  public let urlComponents: URLComponents
  
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
    var urlComponents: URLComponents = .init()
    urlComponents.scheme = scheme
    urlComponents.host = host
    urlComponents.port = port
    self.urlComponents = urlComponents
    self.urlSession = urlSession
  }

  public func make<Request>(
    _ request: Request,
    _ callback: @escaping ResultCallback<Request.Response, NetworkError>
  ) where URLNetworkSession == Request.Session, Request: NetworkRequest {
    Request
    .httpRequest(for: request, in: self)
    .onSuccess { httpRequest in
      make(request: httpRequest, withTimeout: Request.timeout) { [weak self] result in
        guard let self = self else { return callback(.failure(.sessionClosed)) }
        callback(
          result
          .mapError { (error: Error) -> NetworkError in
            switch error {
            case let networkError as NetworkError:
              return networkError
            case _: return .internalInconsistency
            }
          }
          .flatMap { Request.response(from: $0, in: self) }
        )
      }
    }
    .onFailure { callback(.failure($0)) }
  }
  
  private func make(
    request: HTTPRequest,
    withTimeout timeout: TimeInterval,
    callback: @escaping ResultCallback<HTTPResponse, NetworkError>
  ) {
    var foundationRequest: URLRequest = .init(url: request.url)
    foundationRequest.httpMethod = request.method.rawValue
    foundationRequest.allHTTPHeaderFields = request.headers.rawDictionary
    foundationRequest.httpBody = request.body
    foundationRequest.timeoutInterval = timeout
    urlSession.dataTask(with: foundationRequest) { data, response, error in
      if let error = error {
        callback(.failure(NetworkError.unableToMakeRequest(reason: error)))
      } else if let response = response as? HTTPURLResponse {
        callback(
          .success(
            HTTPResponse(
              url: response.url ?? request.url,
              statusCode: HTTPStatusCode(rawValue: response.statusCode) ?? .custom(response.statusCode),
              headers: HTTPHeaders(from: response.allHeaderFields),
              body: data ?? .init()
            )
          )
        )
      } else {
        callback(.failure(NetworkError.internalInconsistency))
      }
    }.resume()
  }
}
