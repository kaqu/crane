public protocol NetworkCall {
  associatedtype Request: NetworkCallRequest where Request.Call == Self
  associatedtype Response: NetworkResponse
  associatedtype Error: NetworkCallError
}

public extension NetworkCall {

  static func httpRequest<Context>(
    for request: Request,
    in context: Context
  ) -> Result<HTTPRequest, Error>
  where Context: NetworkSession {
    Request
      .httpRequest(for: request, in: context)
      .mapError(Error.init)
  }
  
  static func response<Context>(
    from response: HTTPResponse,
    in context: Context
  ) -> Result<Response, Error>
  where Context: NetworkSession {
    Response
      .from(response, in: context)
      .mapError(Error.init)
  }
}
