public protocol NetworkCall {
  associatedtype Request: NetworkRequest
  associatedtype Response: NetworkResponse
}

public extension NetworkCall {
  static func httpRequest(for request: Request, with parameters: Parameters) -> Result<HTTPRequest, NetworkError> {
    Request.httpRequest(for: request, with: parameters)
  }
  
  static func response(from response: HTTPResponse) -> Result<Response, NetworkError> {
    Response.from(response)
  }
  
  static func parameters(for request: Request, with parameters: Parameters) -> Parameters {
    Request.parameters(for: request, with: parameters)
  }
}
