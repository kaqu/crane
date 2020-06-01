public protocol NetworkCall {
  associatedtype Request: NetworkCallRequest where Request.Call == Self
  associatedtype Response: NetworkResponse
  associatedtype Error: NetworkCallError
}

public extension NetworkCall {

  static func httpRequest<Session>(
    for request: Request,
    in context: Session
  ) -> Result<HTTPRequest, Error>
  where Session: NetworkSession {
    Request
      .httpRequest(for: request, in: context)
      .mapError(Error.init)
  }
  
  static func response<Session>(
    from response: HTTPResponse,
    in context: Session
  ) -> Result<Response, Error>
  where Session: NetworkSession {
    Response
      .from(response, in: context)
      .mapError(Error.init)
  }
}
