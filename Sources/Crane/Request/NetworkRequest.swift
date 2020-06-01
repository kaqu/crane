public protocol NetworkRequest {
  
  associatedtype Body
  
  var urlPath: URLPath { get }
  var urlQuery: URLQuery { get }
  var httpMethod: HTTPMethod { get }
  var httpHeaders: HTTPHeaders { get }
  var httpBody: Body { get }
  var timeout: TimeInterval { get }
  
  static func urlQuery<Session>(
    for request: Self,
    in context: Session
  ) -> Result<URLQuery, NetworkError>
  where Session: NetworkSession
  
  static func url<Session>(
    for request: Self,
    in context: Session
  ) -> Result<URL, NetworkError>
  where Session: NetworkSession
  
  static func httpHeaders<Session>(
    for request: Self,
    in context: Session
  ) -> Result<HTTPHeaders, NetworkError>
  where Session: NetworkSession
  
  static func httpBodyData<Session>(
    for request: Self,
    in context: Session
  ) -> Result<Data, NetworkError>
  where Session: NetworkSession
  
  static func httpRequest<Session>(
    for request: Self,
    in context: Session
  ) -> Result<HTTPRequest, NetworkError>
  where Session: NetworkSession
}

// MARK: - Defaults
public extension NetworkRequest {

  var urlQuery: URLQuery { [] }
  var httpMethod: HTTPMethod { .get }
  var httpHeaders: HTTPHeaders { [:] }
  var timeout: TimeInterval { 30 }
  
  static func urlQuery<Session>(
    for request: Self,
    in context: Session
  ) -> Result<URLQuery, NetworkError>
  where Session: NetworkSession {
    .success(request.urlQuery)
  }
  
  static func url<Session>(
    for request: Self,
    in context: Session
  ) -> Result<URL, NetworkError>
  where Session : NetworkSession {
    urlQuery(for: request, in: context)
    .flatMap  { query in
      var urlComponents = context.urlBase
      urlComponents.percentEncodedPath = request.urlPath.percentEncodedString
      urlComponents.query = query.queryString
      guard let url = urlComponents.url
      else { return .failure(.invalidURL) }
      return .success(url)
    }
  }
  
  static func httpHeaders<Session>(
    for request: Self,
    in context: Session
  ) -> Result<HTTPHeaders, NetworkError>
  where Session: NetworkSession {
    .success(request.httpHeaders)
  }
  
  static func httpRequest<Session>(
    for request: Self,
    in context: Session
  ) -> Result<HTTPRequest, NetworkError>
  where Session: NetworkSession {
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
  
  static func httpBodyData<Session>(
    for request: Self,
    in context: Session
  ) -> Result<Data, NetworkError>
  where Session: NetworkSession {
    .success(Data())
  }
}

// MARK: - Data request body
public extension NetworkRequest where Body == Data {
  
  static func httpBodyData<Session>(
    for request: Self,
    in context: Session
  ) -> Result<Data, NetworkError>
  where Session: NetworkSession {
    .success(request.httpBody)
  }
}

// MARK: - JSON request body
public protocol JSONBodyNetworkRequest: NetworkRequest where Body: Encodable {
  static var jsonEncoder: JSONEncoder { get }
}

private let defaultJSONEncoder: JSONEncoder = .init()

public extension JSONBodyNetworkRequest {
  static var jsonEncoder: JSONEncoder { defaultJSONEncoder }
  static var httpHeaders: HTTPHeaders { ["content-type": "application/json"] }
  static func httpBodyData<Session>(
    for request: Self,
    in context: Session
  ) -> Result<Data, NetworkError>
  where Session: NetworkSession {
    Result {
      try jsonEncoder.encode(request.httpBody)
    }
    .mapError { error in
      NetworkError.unableToEncodeRequestBody(reason: error)
    }
  }
}
