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
  static func parameters(for request: Self, with parameters: Parameters) -> Result<Parameters, ParameterError> // parameters merge
}

// MARK: - Defaults
public extension NetworkRequest {
  
  var parameters: Parameters { [] }
  
  // all requested parameters
  static var parameters: Result<Parameters, ParameterError> {
    path.parameters
    .updated(with: query.parameters)
    .flatMap { $0.updated(with: headers.parameters) }
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
    parameters.value(of: String.self, for: "host")
      .flatMap { host in
        parameters.value(of: String?.self, for: "scheme")
          .flatMap { scheme in
            parameters.value(of: Int?.self, for: "port")
              .map { port in
                (scheme: scheme, host: host, port: port)
            }
        }
    }
    .mapError(NetworkError.parameterError)
    .flatMap { (scheme, host, port) in
      URL.using(
        scheme: scheme ?? "https",
        host: host,
        port: port,
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
    self.parameters(for: request, with: parameters)
    .mapError(NetworkError.parameterError)
    .flatMap { finalParameters in
      url(for: request, with: finalParameters)
      .flatMap { url in
        headers.resolve(using: finalParameters)
        .mapError { NetworkError.httpError($0) }
        .flatMap { headersDict in
          encodeBody(request.body, with: finalParameters)
          .map { bodyData in
            HTTPRequest.init(method: method.rawValue, url: url, headers: headersDict, body: bodyData)
          }
          .mapError { NetworkError.unableToEncodeRequestBody(reason: $0) }
        }
      }
    }
    
  }
  
  static func parameters(
    for request: Self,
    with parameters: Parameters
  ) -> Result<Parameters, ParameterError> {
    Self.parameters
    .flatMap { $0.updated(with: parameters) }
    .flatMap { $0.updated(with: request.parameters) }
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
