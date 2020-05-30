public protocol NetworkRequest {
  associatedtype Body
  var urlPath: URLPath { get }
  var urlQuery: URLQuery { get }
  var httpMethod: HTTPMethod { get }
  var httpHeaders: HTTPHeaders { get }
  var httpBody: Body { get }
  var timeout: TimeInterval { get }
  
  static func urlQuery<Context>(
    for request: Self,
    in context: Context
  ) -> Result<URLQuery, NetworkError>
  where Context : NetworkSession
  
  static func url<Context>(
    for request: Self,
    in context: Context
  ) -> Result<URL, NetworkError>
  where Context : NetworkSession
  
  static func httpHeaders<Context>(
    for request: Self,
    in context: Context
  ) -> Result<HTTPHeaders, NetworkError>
  where Context : NetworkSession
  
  static func httpBodyData<Context>(
    for request: Self,
    in context: Context
  ) -> Result<Data, NetworkError>
  where Context : NetworkSession
  
  static func httpRequest<Context>(
    for request: Self,
    in context: Context
  ) -> Result<HTTPRequest, NetworkError>
  where Context : NetworkSession
}

// MARK: - Defaults
public extension NetworkRequest {

  var urlQuery: URLQuery { [] }
  var httpMethod: HTTPMethod { .get }
  var httpHeaders: HTTPHeaders { [:] }
  var timeout: TimeInterval { 30 }
  
  static func urlQuery<Context>(
    for request: Self,
    in context: Context
  ) -> Result<URLQuery, NetworkError>
  where Context : NetworkSession {
    .success(request.urlQuery)
  }
  
  static func url<Context>(
    for request: Self,
    in context: Context
  ) -> Result<URL, NetworkError>
  where Context : NetworkSession {
    urlQuery(for: request, in: context)
    .flatMap  { query in
      var urlComponents = context.urlBase
      urlComponents.path = request.urlPath.pathString
      urlComponents.query = query.queryString
      guard let url = urlComponents.url
      else { return .failure(.invalidURL) }
      return .success(url)
    }
  }
  
  static func httpHeaders<Context>(
    for request: Self,
    in context: Context
  ) -> Result<HTTPHeaders, NetworkError>
  where Context : NetworkSession {
    .success(request.httpHeaders)
  }
  
  static func httpRequest<Context>(
    for request: Self,
    in context: Context
  ) -> Result<HTTPRequest, NetworkError>
  where Context : NetworkSession {
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
  
  static func httpBodyData<Context>(
    for request: Self,
    in context: Context
  ) -> Result<Data, NetworkError>
  where Context : NetworkSession {
    .success(Data())
  }
}

// MARK: - JSON request
public protocol JSONNetworkRequest: NetworkRequest where Body: Encodable {
  static var jsonEncoder: JSONEncoder { get }
}

private let defaultJSONEncoder: JSONEncoder = .init()

public extension JSONNetworkRequest {
  static var jsonEncoder: JSONEncoder { defaultJSONEncoder }
  static var httpHeaders: HTTPHeaders { ["content-type": "application/json"] }
  static func httpBodyData<Context>(
    for request: Self,
    in context: Context
  ) -> Result<Data, NetworkError>
  where Context : NetworkSession {
    Result {
      try jsonEncoder.encode(request.httpBody)
    }
    .mapError { error in
      NetworkError.unableToEncodeRequestBody(reason: error)
    }
  }
}
