import Foundation

/// Basic request expecting some response.
public protocol NetworkRequest: Request where Session: NetworkSession {
  // MARK: - Type specification
  /// Response type associated and expected for this request
  associatedtype Response: NetworkResponse
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
  
  static func response(
    from response: HTTPResponse,
    in session: Session
  ) -> Result<Response, NetworkError> {
    Response.from(response)
  }
}

// MARK: - JSON request
/// Basic request with JSON body expecting some response.
public protocol JSONNetworkRequest: NetworkRequest where Body: Encodable {
  /// Encoder used to encode json for request body.
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
