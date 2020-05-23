public protocol NetworkResponse {
  static func from<Context>(_ response: HTTPResponse, in context: Context) -> Result<Self, NetworkError>
}

// MARK: - JSON response

public protocol JSONNetworkResponse: NetworkResponse, Decodable {
  static var jsonDecoder: JSONDecoder { get }
}

private let defaultJSONDecoder: JSONDecoder = .init()

public extension JSONNetworkResponse {
  static var jsonDecoder: JSONDecoder { defaultJSONDecoder }
  static func from<Context>(_ response: HTTPResponse, in context: Context) -> Result<Self, NetworkError> {
    Result {
      try jsonDecoder.decode(Self.self, from: response.body)
    }
    .mapError { error in
      NetworkError.unableToDecodeResponse(response, reason: error)
    }
  }
}
