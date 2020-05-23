public protocol NetworkRequestContext {
  var baseURL: URL { get }
}

public protocol NetworkRequest {
  associatedtype Body
  var urlPath: URLPath { get }
  var urlQuery: URLQuery { get }
  var httpMethod: HTTPMethod { get }
  var httpHeaders: HTTPHeaders { get }
  var httpBody: Body { get }
  var timeout: TimeInterval { get }
  
  static func urlQuery<Context: NetworkRequestContext>(for request: Self, in context: Context) -> Result<URLQuery, NetworkError>
  static func url<Context: NetworkRequestContext>(for request: Self, in context: Context) -> Result<URL, NetworkError>
  static func httpHeaders<Context: NetworkRequestContext>(for request: Self, in context: Context) -> Result<HTTPHeaders, NetworkError>
  static func httpBodyData<Context: NetworkRequestContext>(for request: Self, in context: Context) -> Result<Data, NetworkError>
  static func httpRequest<Context: NetworkRequestContext>(for request: Self, in context: Context) -> Result<HTTPRequest, NetworkError>
}

// MARK: - Defaults
public extension NetworkRequest {

  var urlQuery: URLQuery { [] }
  var httpMethod: HTTPMethod { .get }
  var httpHeaders: HTTPHeaders { [:] }
  var timeout: TimeInterval { 30 }
  
  static func urlQuery<Context: NetworkRequestContext>(for request: Self, in context: Context) -> Result<URLQuery, NetworkError> {
    .success(request.urlQuery)
  }
  
  static func url<Context: NetworkRequestContext>(for request: Self, in context: Context) -> Result<URL, NetworkError> {
    .success(context.baseURL.appendingPathComponent(request.urlPath.pathString))
  }
  
  static func httpHeaders<Context: NetworkRequestContext>(for request: Self, in context: Context) -> Result<HTTPHeaders, NetworkError> {
    .success(request.httpHeaders)
  }
  
  static func httpRequest<Context: NetworkRequestContext>(for request: Self, in context: Context) -> Result<HTTPRequest, NetworkError> {
    url(for: request, in: context)
    .flatMap { url in
      httpHeaders(for: request, in: context)
      .flatMap { headers in
        httpBodyData(for: request, in: context)
        .map { bodyData in
          HTTPRequest(
            request.httpMethod,
            url: url,
            headers: headers,
            body: bodyData
          )
        }
      }
    }
  }
}

// MARK: - Void request body
public extension NetworkRequest where Body == Void {
  var httpBody: Body { () }
}

// MARK: - JSON request
public protocol JSONNetworkRequest: NetworkRequest where Body: Encodable {
  static var jsonEncoder: JSONEncoder { get }
}

private let defaultJSONEncoder: JSONEncoder = .init()

public extension JSONNetworkRequest {
  static var jsonEncoder: JSONEncoder { defaultJSONEncoder }
  static var httpHeaders: HTTPHeaders { ["content-type": "application/json"] }
  static func httpBodyData<Context: NetworkRequestContext>(for request: Self, in context: Context) -> Result<Data, NetworkError> {
    Result {
      try jsonEncoder.encode(request.httpBody)
    }
    .mapError { error in
      NetworkError.unableToEncodeRequestBody(reason: error)
    }
  }
}
