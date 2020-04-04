public protocol NetworkSession {
  var parameters: Parameters { get }
  func make(
    request: HTTPRequest,
    withTimeout timeout: TimeInterval,
    callback: @escaping ResultCallback<HTTPResponse, NetworkError>
  ) // TODO: allow cancelation
}

extension NetworkSession {
  func make<Call: NetworkCall>(
    _ call: Call.Type = Call.self,
    _ request: Call.Request,
    _ callback: @escaping ResultCallback<Call.Response, NetworkError>
  ) { // TODO: allow cancelation
    switch Call.httpRequest(for: request, with: self.parameters) {
    case let .success(httpRequest):
      make(request: httpRequest, withTimeout: Call.Request.timeout) { result in
        callback(
          result
            .mapError { (error: Error) -> NetworkError in
              switch error {
              case let networkError as NetworkError:
                return networkError
              case _: return .internalInconsistency
              }
          }
          .flatMap { Call.response(from: $0) }
        )
      }
    case let .failure(error):
      callback(.failure(error))
    }
  }
}
