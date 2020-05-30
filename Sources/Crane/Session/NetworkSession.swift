import struct Foundation.NSURL.URLComponents

public protocol NetworkSession: AnyObject {
  var urlBase: URLComponents { get }
  
  @discardableResult
  func make(
    request: HTTPRequest,
    withTimeout timeout: TimeInterval,
    callback: @escaping ResultCallback<HTTPResponse, NetworkError>
  ) -> CancelationToken
}

extension NetworkSession {

  @discardableResult
  func make<Call>(
    _ call: Call.Type = Call.self,
    _ request: Call.Request,
    _ callback: @escaping ResultCallback<Call.Response, NetworkError>
  ) -> CancelationToken
  where Call: NetworkCall {
    switch Call.httpRequest(for: request, in: self) {
    case let .success(httpRequest):
      return make(request: httpRequest, withTimeout: request.timeout) { [weak self] result in
        callback(
          result
          .flatMap { [weak self] httpResponse in
            guard let self = self else { return .failure(.sessionClosed)}
            return Call.response(from: httpResponse, in: self)
          }
        )
      }
    case let .failure(error):
      callback(.failure(error))
      return CancelationToken {}
    }
  }
}
