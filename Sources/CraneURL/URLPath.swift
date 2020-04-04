import CraneParameters

public struct URLPath {

  private var parts: Array<StringOrParameter>
  
  fileprivate init(parts: Array<StringOrParameter>) {
    self.parts = parts
  }
  
  public var parameters: Parameters {
    .init(parts.compactMap { $0.parameter})
  }

  public mutating func append(_ other: URLPath) {
    parts.append(contentsOf: other.parts)
  }
  
  public func appending(_ other: URLPath) -> URLPath{
    var copy = self
    copy.parts.append(contentsOf: other.parts)
    return copy
  }
  
  public func resolve(using parameters: Parameters? = nil) -> Result<String, URLError> {
    switch parameters.map(self.parameters.updated(with:)) ?? .success(self.parameters) {
    case let .success(parameters):
      do {
        return try .success(
          parts
          .compactMap { (part: StringOrParameter) throws -> String? in
            switch part {
            case let .string(string):
              guard let value = string
                .split(separator: "/")
                .reduce(into: "", { $0.append("/\($1)") })
                .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
              else { throw URLError.invalidEncoding }
              return value
            case let .parameter(parameter):
              switch parameters.validate(parameter.name) {
              case .success:
                guard let rawValue = parameters.stringValue(for: parameter) else { return nil }
                guard let value = rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                else { throw URLError.invalidEncoding }
                return "/\(value)"
              case let .failure(validationError):
                throw URLError.parameterError(.invalid(parameter.name, error: validationError))
              }
            }
          }
          .reduce(into: "", { $0.append($1) })
        )
      } catch let error as URLError {
        return .failure(error)
      } catch { fatalError("Never") }
    case let .failure(error):
      return .failure(URLError.parameterError(error))
    }
  }
}

extension URLPath: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    self.init(parts: [.string(stringLiteral)])
  }
}

extension URLPath: ExpressibleByArrayLiteral {
  public init(arrayLiteral parts: StringOrParameter...) {
    self.init(parts: parts.map { $0 })
  }
}

extension URLPath {
  public init(@URLPathTemplateBuilder _ builder: () -> URLPath) {
    self = builder()
  }
}

@_functionBuilder
public enum URLPathTemplateBuilder {
  public static func buildBlock(_ parts: StringOrParameter...) -> URLPath {
    .init(parts: parts.map { $0 } )
  }
}
