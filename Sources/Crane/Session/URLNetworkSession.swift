import Foundation

/// Minimal NetworkSession implementation using Foundation.URLSession.
public final class URLNetworkSession: SessionContext {

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
}

extension URLNetworkSession: NetworkSession {
  
  public func make<Request>(
    _ request: Request,
    _ callback: @escaping ResultCallback<Request.Response, NetworkError>
  ) where URLNetworkSession == Request.Session, Request: NetworkRequest {
    switch Request.httpRequest(for: request, in: self) {
    case let .success(httpRequest):
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
    case let .failure(error):
      callback(.failure(error))
    }
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

extension URLNetworkSession: NetworkDownloadSession {
  
  public func make<Request>(
    _ request: Request,
    _ callback: @escaping ResultCallback<URL, NetworkError>
  ) where URLNetworkSession == Request.Session, Request: NetworkDownloadRequest {
    switch Request.httpRequest(for: request, in: self) {
    case let .success(httpRequest):
      make(download: httpRequest, withTimeout: Request.timeout) { [weak self] result in
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
          .flatMap { tempFileURL in
            Request
              .downloadDestinationURL(for: request, in: self)
              .flatMap { destinationURL in
                do {
                  // TODO: to check
                  try? FileManager.default
                    .createDirectory(at: destinationURL,
                                     withIntermediateDirectories: true,
                                     attributes: nil)
                  try? FileManager.default
                    .removeItem(at: destinationURL)
                  try FileManager.default
                    .moveItem(at: tempFileURL, to: destinationURL)
                  return .success(destinationURL)
                } catch {
                  return .failure(.other(error)) // TODO: it might be some better error handling
                }
              }
          }
        )
      }
    case let .failure(error):
      callback(.failure(error))
    }
  }
  
  private func make(
    download request: HTTPRequest,
    withTimeout timeout: TimeInterval,
    callback: @escaping ResultCallback<URL, NetworkError>
  ) {
    var foundationRequest: URLRequest = .init(url: request.url)
    foundationRequest.httpMethod = request.method.rawValue
    foundationRequest.allHTTPHeaderFields = request.headers.rawDictionary
    foundationRequest.httpBody = request.body
    foundationRequest.timeoutInterval = timeout
    urlSession.downloadTask(with: foundationRequest) { url, response, error in
      if let error = error {
        callback(.failure(.unableToMakeRequest(reason: error)))
      } else if let fileURL = url {
        callback(.success(fileURL))
        // } else if let response = response as? HTTPURLResponse {
        // TODO: handle some other errors?
      } else {
        callback(.failure(.internalInconsistency))
      }
    }.resume()
  }
}


extension URLNetworkSession: NetworkConnectionSession {
  
  public func make<Request>(
    _ request: Request,
    _ callback: @escaping ResultCallback<NetworkConnection<Request>, NetworkError>
  ) where URLNetworkSession == Request.Session, Request: NetworkConnectionRequest {
    fatalError("Not implemented yet") // TODO: FIXME: to complete
    switch Request.httpRequest(for: request, in: self) {
    case let .success(httpRequest):
      if #available(iOS 13.0, *) { // TODO: FIXME: temp
        let webSocketTask: URLSessionWebSocketTask = prepare(connection: httpRequest, withTimeout: Request.timeout)
        defer { webSocketTask.resume() }
        let ping: (@escaping ResultCallback<Void, Error>) -> Void
          = { callback in
            webSocketTask.sendPing { error in
              switch error {
              case let .some(error):
                callback(.failure(error))
              case .none:
                callback(.success(()))
              }
            }
        }
        let send: (Data, @escaping ResultCallback<Void, Error>) -> Void
          = { data, callback in
            webSocketTask.send(.data(data)) { error in
              switch error {
              case let .some(error):
                callback(.failure(error))
              case .none:
                callback(.success(()))
              }
            }
        }
        let receive: (@escaping ResultCallback<Data, Error>) -> Void
          = { callback in
            webSocketTask.receive { result in
              callback(
                result.flatMap {
                  switch $0 {
                  case let .data(data):
                    return .success(data)
                  case let .string(string):
                    switch string.data(using: .utf8) {
                    case let .some(data):
                      return .success(data)
                    case .none:
                      return .failure(NetworkConnectionError.todo) // TODO: FIXME
                    }
                  case _:
                    return .failure(NetworkConnectionError.todo) // TODO: FIXME
                  }
                }
              )
            }
        }
        let close: (@escaping ResultCallback<Void, Error>) -> Void
          = { callback in
            webSocketTask.cancel(with: .normalClosure, reason: nil)
        }
      } else {
        fatalError("Not implemented yet") // TODO: FIXME: to complete
      }
    case let .failure(error):
      callback(.failure(error))
    }
  }
  
  @available(iOS 13.0, *)
  private func prepare(
    connection request: HTTPRequest,
    withTimeout timeout: TimeInterval
  ) -> URLSessionWebSocketTask {
    var foundationRequest: URLRequest = .init(url: request.url)
    foundationRequest.httpMethod = request.method.rawValue
    foundationRequest.allHTTPHeaderFields = request.headers.rawDictionary
    foundationRequest.httpBody = request.body
    foundationRequest.timeoutInterval = timeout
    return urlSession.webSocketTask(with: foundationRequest)
  }
}
