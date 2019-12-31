/// HTTP method.
public enum HTTPMethod {
  case get
  case put
  case post
  case patch
  case delete
  case options
  case head
  case custom(String)
}

extension HTTPMethod: RawRepresentable {

  public init?(rawValue: String) {
    switch rawValue.uppercased() {
    case "GET": self = .get
    case "PUT": self = .put
    case "POST": self = .post
    case "PATCH": self = .patch
    case "DELETE": self = .delete
    case "OPTIONS": self = .options
    case "HEAD": self = .head
    case let method:
      guard method.allSatisfy(isASCII) else {
        return nil
      }
      self = .custom(method)
    }
  }

  public var rawValue: String {
    switch self {
    case .get: return "GET"
    case .put: return "PUT"
    case .post: return "POST"
    case .patch: return "PATCH"
    case .delete: return "DELETE"
    case .options: return "OPTIONS"
    case .head: return "HEAD"
    case let .custom(method): return method
    }
  }
}
