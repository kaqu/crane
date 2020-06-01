public protocol NetworkResponse {
  
  static func from<Session>(
    _ response: HTTPResponse,
    in context: Session
  ) -> Result<Self, NetworkError>
  where Session: NetworkSession
}

// MARK: - JSON response

public protocol JSONBodyNetworkResponse: NetworkResponse, Decodable {
  
  static var jsonDecoder: JSONDecoder { get }
}

private let defaultJSONDecoder: JSONDecoder = .init()

public extension JSONBodyNetworkResponse {
  
  static var jsonDecoder: JSONDecoder { defaultJSONDecoder }
  
  static func from<Session>(
    _ response: HTTPResponse,
    in context: Session
  ) -> Result<Self, NetworkError>
  where Session: NetworkSession {
    Result {
      try jsonDecoder.decode(Self.self, from: response.body)
    }
    .mapError { error in
      NetworkError.unableToDecodeResponse(response, reason: error)
    }
  }
}
