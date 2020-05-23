public protocol NetworkCall {
  associatedtype Request: NetworkRequest
  associatedtype Response: NetworkResponse
}

public extension NetworkCall {
  static func httpRequest<Context: NetworkRequestContext>(for request: Request, in context: Context) -> Result<HTTPRequest, NetworkError> {
    Request.httpRequest(for: request, in: context)
  }
  
  static func response<Context>(from response: HTTPResponse, in context: Context) -> Result<Response, NetworkError> {
    Response.from(response, in: context)
  }
}
