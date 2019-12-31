import Foundation

/// Abstraction over any HTTP network response.
/// Used as part of NetworkRequest description.
/// Can be used to describe structure of response.
public protocol NetworkResponse {
  /// Function used to create instance of response from raw HTTP response.
  /// - parameter response: raw http response received from network
  /// - returns: result of received response interpretation
  static func from(_ response: HTTPResponse) -> Result<Self, NetworkError>
}

// MARK: - JSON response
public protocol JSONNetworkResponse: NetworkResponse, Decodable {
  static var jsonDecoder: JSONDecoder { get }
}

private let defaultJSONDecoder: JSONDecoder = .init()

public extension JSONNetworkResponse {
  static var jsonDecoder: JSONDecoder { defaultJSONDecoder }
  static func from(_ response: HTTPResponse) -> Result<Self, NetworkError> {
    Result { try jsonDecoder.decode(Self.self, from: response.body) }
      .mapError { error in
        NetworkError.unableToDecodeResponse(response, reason: error)
      }
  }
}
