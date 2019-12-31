import Foundation

/// Template for URL path used to make acctual urls.
/// Might contain parameters that will be resolved dynamically.
/// Parameters should be specified by names between `{` and `}`
/// in path i.e. `/service/{id}` contains parameter "id".
/// Have to be constructed as StaticString.
public struct URLPathTemplate {

  private var parts: Array<Part>

  private enum Part {
    case raw(String)
    case parameter(String)
  }

  /// Prepare url based on template and provided arguments.
  /// - parameter components: URL components to be used.
  /// Should contain all required elements except path and query which will be replaced in final URL.
  /// - parameter parameters: URL parameters to be used.
  /// - parameter query: URL query to be used.
  /// - returns: URL that is result of combining arguments with template or error.
  public func buildURL(
    using components: URLComponents,
    with parameters: URLParameters,
    and query: URLQuery
  ) -> Result<URL, NetworkError>
  {
    var components = components
    do {
      components.path
      = try "/"
      + parts
      .map {
        switch $0 {
        case let .raw(part): return part
        case let .parameter(name):
          guard let parameterValue = parameters[name]
          else { throw NetworkError.missingURLParameter(name) }
          return parameterValue
        }
      }
      .joined(separator: "/")
    } catch let networkError as NetworkError {
      return .failure(networkError)
    } catch { fatalError("Unreachable") }
    components.queryItems = query.items
    guard let url = components.url
      else { return .failure(NetworkError.invalidURL) }
    return .success(url)
  }
}

extension URLPathTemplate: ExpressibleByStringLiteral {
  public init(stringLiteral: StaticString) {
    self.parts
      = stringLiteral
      .string
      .split(separator: "/")
      .map {
        if $0.hasPrefix("{") && $0.hasSuffix("}") {
          let parameterName: Substring = $0.dropFirst().dropLast()
          precondition(!parameterName.isEmpty, "Invalid URLPathTemplate")
          return .parameter(String(parameterName))
        } else if $0.allSatisfy(isURLPathAllowed) {
          return .raw(String($0))
        } else {
          fatalError("Invalid URLPathTemplate")
        }
      }
  }
}
