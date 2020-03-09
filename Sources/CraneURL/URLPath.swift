import CraneParameters

public struct URLPath {

  private var parts: Array<ValueOrParameter>
  
  fileprivate init(parts: Array<ValueOrParameter>) {
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
    let parameters = parameters.map(self.parameters.updated(with:)) ?? self.parameters
    do {
      return try .success(
        parts
        .compactMap { (part: ValueOrParameter) throws -> String? in
          switch part {
          case let .value(string):
            return string
            .split(separator: "/")
            .reduce(into: "", { $0.append("/\($1)") })
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
          case let .parameter(parameter):
            if let value = parameters.anyValue(for: parameter) {
              guard parameters.isValid(parameter.name)
              else { throw URLError.invalidParameter(parameter.name, value: String(describing: value)) }
              return "/\(value)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            } else if parameters.isOptional(parameter.name) {
              return nil
            } else {
              throw URLError.missingParameter(parameter.name)
            }
          }
        }
        .reduce(into: "", { $0.append($1) })
      )
    } catch let error as URLError {
      return .failure(error)
    } catch { fatalError("Never") }
  }
}

extension URLPath: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    self.init(parts: [.value(stringLiteral)])
  }
}

extension URLPath: ExpressibleByArrayLiteral {
  public init(arrayLiteral parts: ValueOrParameter...) {
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
  public static func buildBlock(_ parts: ValueOrParameter...) -> URLPath {
    .init(parts: parts.map { $0 } )
  }
}
