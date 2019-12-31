import Foundation

/// Abstraction over any HTTP network request.
/// Should be used as base for defining request and associated response description.
/// Request type contains base attributes of acctual network request.
/// Requesrt instance contains concrete request specific properties
/// that will be used to make that specific request.
public protocol NetworkRequest {
  // MARK: - Type specification
  /// Session type that can be used to execute this type of request
  associatedtype Session: NetworkSession
  /// Type of HTTP body for this request
  associatedtype Body
  /// Response type associated and expected for this request
  associatedtype Response: NetworkResponse
  // MARK: - Instance request parts
  /// URL query for specific request. Will override base value for this request.
  var urlQuery: URLQuery { get }
  /// URL parameters for specific request. Will override base value for this request.
  var urlParameters: URLParameters { get }
  /// HTTP headers for specific request. Will override base value for this request.
  var httpHeaders: HTTPHeaders { get }
  /// Body for specific request. Will be encoded as HTTP body.
  var httpBody: Body { get }
  /// Function used to encode request body to HTTP body data.
  /// - parameter httpBody: instance of defined HTTPBody to be encoded.
  /// - returns: result of data encoding
  static func encodeBody(_ httpBody: Body) -> Result<Data, Error>
  // MARK: - Request configuration
  /// Timeout in seconds for waiting for this request's response.
  /// Default value is 30 seconds.
  static var timeout: TimeInterval { get }
  // TODO: add cache policy
  // MARK: - Base request parts
  /// HTTP method used by this request.
  /// Default value is GET.
  static var httpMethod: HTTPMethod { get }
  /// Template for URL path used to make this request.
  /// Might contain parameters that will be resolved
  /// when executing specific request.
  /// Parameters should be specified by names between `{` and `}`
  /// in path i.e. `/service/{id}` contains parameter "id".
  static var urlPathTemplate: URLPathTemplate { get }
  /// Base url query for this request. Might be overriden be specific request.
  /// Default value is empty.
  static var urlQuery: URLQuery { get }
  /// Base url parameters for this request. Might be overriden be specific request.
  /// Default value is empty.
  static var urlParameters: URLParameters { get }
  /// Base http headers for this request. Might be overriden be specific request.
  /// Default value is empty.
  static var httpHeaders: HTTPHeaders { get }
  // MARK: - Final request parts
  /// Function preparing final url query used to execute request.
  /// Provides access to associated session.
  /// Default implementation if will merge base and request specific parameters.
  /// - warning: When you provide costom implementation for this fuction
  /// you have to manage both type and instance urlQuery manually.
  /// Result of this function will define final properties of request.
  /// - parameter request: instance of specific request to be executed
  /// - parameter session: instance of specific session executing request
  /// - returns: result of query preparation
  static func urlQuery(for request: Self, in session: Session) -> Result<URLQuery, NetworkError>
  /// Function preparing final url parameters used to execute request.
  /// Provides access to associated session.
  /// Default implementation if will merge base and request specific parameters.
  /// - warning: When you provide costom implementation for this fuction
  /// you have to manage both type and instance urlParameters manually.
  /// Result of this function will define final properties of request.
  /// - parameter request: instance of specific request to be executed
  /// - parameter session: instance of specific session executing request
  /// - returns: result of parameters preparation
  static func urlParameters(for request: Self, in session: Session) -> Result<URLParameters, NetworkError>
  /// Function preparing final url used to execute request.
  /// Provides access to associated session.
  /// Default implementation if will merge session components and path template.
  /// It will take into account urlQuery and urlParameters function result.
  /// - warning: When you provide costom implementation for this fuction
  /// you have to manage all attributes manually.
  /// Result of this function will define final properties of request.
  /// - parameter request: instance of specific request to be executed
  /// - parameter session: instance of specific session executing request
  /// - returns: result of url preparation
  static func url(for request: Self, in session: Session) -> Result<URL, NetworkError>
  /// Function preparing final http headers used to execute request.
  /// Provides access to associated session.
  /// Default implementation if will merge base and request specific parameters.
  /// - warning: When you provide costom implementation for this fuction
  /// you have to manage both type and instance httpHeaders manually.
  /// Result of this function will define final properties of request.
  /// - parameter request: instance of specific request to be executed
  /// - parameter session: instance of specific session executing request
  /// - returns: result of headers preparation
  static func httpHeaders(for request: Self, in session: Session) -> Result<HTTPHeaders, NetworkError>
  /// Function preparing final http body used to execute request.
  /// Provides access to associated session.
  /// Default implementation if will use httpBody and encodeBody.
  /// - warning: When you provide costom implementation for this fuction
  /// you have to manage both instance httpBody and encodeBody manually.
  /// Result of this function will define final properties of request.
  /// - parameter request: instance of specific request to be executed
  /// - parameter session: instance of specific session executing request
  /// - returns: result of body data preparation
  static func httpBodyData(for request: Self, in session: Session) -> Result<Data, NetworkError>
  /// Function preparing final http request used to execute.
  /// Provides access to associated session.
  /// Default implementation if will use all required functions and parametets.
  /// - warning: When you provide costom implementation for this fuction
  /// you have to manage all properties manually.
  /// Result of this function will define final request.
  /// - warning: Request configuration like i.e. timeout must be interpreted by session
  /// since this is not part of http request itself.
  /// - parameter request: instance of specific request to be executed
  /// - parameter session: instance of specific session executing request
  /// - returns: result of request preparation
  static func httpRequest(for request: Self, in session: Session) -> Result<HTTPRequest, NetworkError>
  // MARK: - Response
  /// Fuction processing received response. Might be used to update session.
  /// Default implementation will use plain Response constructor without any additional operations.
  /// - parameter response: HTTP response to be interpreted
  /// - parameter session: instance of specific session executing request
  /// - returns: result of response interpretation and processing.
  static func response(from response: HTTPResponse, in session: Session) -> Result<Response, NetworkError>
}

// MARK: - Defaults
public extension NetworkRequest {

  var urlQuery: URLQuery { [] }
  var urlParameters: URLParameters { [] }
  var httpHeaders: HTTPHeaders { [] }

  static var timeout: TimeInterval { 30 }
  static var urlQuery: URLQuery { [] }
  static var urlParameters: URLParameters { [] }
  static var httpHeaders: HTTPHeaders { [] }

  static func url(
    for request: Self,
    in session: Session
  ) -> Result<URL, NetworkError> {
    urlParameters(for: request, in: session)
    .flatMap { urlParameters in
      urlQuery(for: request, in: session)
      .flatMap { urlQuery in
        Self.urlPathTemplate
        .buildURL(
          using: session.urlComponents,
          with: urlParameters,
          and: urlQuery
        )
      }
    }
  }

  static func httpHeaders(
    for request: Self,
    in session: Session
  ) -> Result<HTTPHeaders, NetworkError> {
    .success(httpHeaders.updated(with: request.httpHeaders))
  }

  static func httpBodyData(
    for request: Self,
    in session: Session
  ) -> Result<Data, NetworkError> {
    Self.encodeBody(request.httpBody).mapError { .unableToEncodeRequestBody(reason: $0) }
  }

  static func urlParameters(
    for request: Self,
    in session: Session
  ) -> Result<URLParameters, NetworkError> {
    .success(urlParameters.updated(with: request.urlParameters))
  }

  static func urlQuery(
    for request: Self,
    in session: Session
  ) -> Result<URLQuery, NetworkError> {
    .success(urlQuery.updated(with: request.urlQuery))
  }
  
  static func httpRequest(
    for request: Self,
    in session: Session
  ) -> Result<HTTPRequest, NetworkError>
  {
    url(for: request, in: session)
    .flatMap { url in
      httpHeaders(for: request, in: session)
      .flatMap { headers in
        httpBodyData(for: request, in: session)
        .map { bodyData in
          HTTPRequest(
            method: Self.httpMethod,
            url: url,
            headers: headers,
            body: bodyData
          )
        }
      }
    }
  }
  
  static func response(
    from response: HTTPResponse,
    in session: Session
  ) -> Result<Response, NetworkError> {
    Response.from(response)
  }
}

// MARK: - Void request body
public extension NetworkRequest where Body == Void {
  static func encodeBody(_ httpBody: Body) -> Result<Data, Error> { .success(.init()) }
  var httpBody: Body { Void() }
}

// MARK: - JSON request
public protocol JSONNetworkRequest: NetworkRequest where Body: Encodable {
  static var jsonEncoder: JSONEncoder { get }
}

private let defaultJSONEncoder: JSONEncoder = .init()

public extension JSONNetworkRequest {
  static var jsonEncoder: JSONEncoder { defaultJSONEncoder }
  static var httpHeaders: HTTPHeaders { ["content-type": "application/json"] }
  static func encodeBody(_ httpBody: Body) -> Result<Data, Error> {
    Result{ try jsonEncoder.encode(httpBody) }
  }
}
