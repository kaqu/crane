import Foundation.NSData
import Foundation.NSDate

import CraneHTTP
import CraneURL

public protocol NetworkRequest {
  // MARK: - Type specification
  associatedtype Body
  // MARK: - Instance request parts
  var parameters: Parameters { get } // final parameters
  var body: Body { get }
  static func encodeBody(_ body: Body, with parameters: Parameters) -> Result<Data, Error>
  // MARK: - Request configuration
  static var timeout: TimeInterval { get }
  // MARK: - Base request part
  static var method: HTTPMethod { get }
  static var path: URLPath { get }
  static var query: URLQuery { get }
  static var headers: HTTPHeaders { get }
  // MARK: - Final request parts
  static func httpRequest(for request: Self, with parameters: Parameters) -> Result<HTTPRequest, NetworkError>
  static func url(for request: Self, with parameters: Parameters) -> Result<URL, NetworkError>
  static func parameters(for request: Self, with parameters: Parameters) -> Parameters // parameters merge
}

// MARK: - Defaults
public extension NetworkRequest {
  
  var parameters: Parameters { [] }
  
  // all requested parameters
  static var parameters: Parameters {
    path.parameters
    .updated(with: query.parameters)
    .updated(with: headers.parameters)
  }
  
  static var timeout: TimeInterval { 30 }
  
  static var method: HTTPMethod { .get }
  static var path: URLPath { "/" }
  static var query: URLQuery { [] }
  static var headers: HTTPHeaders { [] }
  
  static func url(
    for request: Self,
    with parameters: Parameters
  ) -> Result<URL, NetworkError> {
    // TODO: FIXME: base - scheme/host/port - just handle it...
    return parameters.value(of: String.self, for: "host")
    .mapError {
      switch $0 {
      case let .missing(parameterName):
        return NetworkError.urlError(.missingParameter(parameterName))
      case let .invalid(parameterName, error: error):
        return NetworkError.urlError(.invalidParameter(parameterName, error: error))
      case let .wrongType(parameterName, _):
        return NetworkError.urlError(.invalidParameter(parameterName, error: $0))
      }
    }
    .flatMap { host in
      URL.using(
        scheme: (try? parameters.value(for: "scheme").get()) ?? "https",
        host: host,
        port: try? parameters.value(for: "port").get(),
        path: path,
        query: query,
        with: parameters
      ).mapError { NetworkError.urlError($0) }
    }
    
  }
  
  static func httpRequest(
    for request: Self,
    with parameters: Parameters
  ) -> Result<HTTPRequest, NetworkError> {
    return url(for: request, with: parameters)
    .flatMap { url in
      headers.resolve(using: parameters)
      .mapError { NetworkError.httpError($0) }
      .flatMap { headersDict in
        encodeBody(request.body, with: parameters)
        .map { bodyData in
          HTTPRequest.init(method: method.rawValue, url: url, headers: headersDict, body: bodyData)
        }
        .mapError { NetworkError.unableToEncodeRequestBody(reason: $0) }
      }
    }
  }
  
  static func parameters(
    for request: Self,
    with parameters: Parameters
  ) -> Parameters {
    Self.parameters
    .updated(with: parameters)
    .updated(with: request.parameters)
  }
}

// MARK: - Void body
public extension NetworkRequest where Body == Void {
  static func encodeBody(_ httpBody: Body, with parameters: Parameters) -> Result<Data, Error> { .success(.init()) }
  var body: Body { Void() }
}

// MARK: - JSON request

public protocol JSONNetworkRequest: NetworkRequest where Body: Encodable {
  static var jsonEncoder: JSONEncoder { get }
}

private let defaultJSONEncoder: JSONEncoder = .init()

public extension JSONNetworkRequest {
  static var jsonEncoder: JSONEncoder { defaultJSONEncoder }
  static var httpHeaders: HTTPHeaders { ["content-type": "application/json"] }
  static func encodeBody(_ httpBody: Body, with parameters: Parameters) -> Result<Data, Error> {
    Result { try jsonEncoder.encode(httpBody) }
  }
}
