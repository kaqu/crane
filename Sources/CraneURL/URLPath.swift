import Foundation
import CraneParameters

public struct URLPath {

  public enum Part {
    case raw(String)
    case parameter(AnyParameter)
  }

  private var store: Array<Part>
  
  fileprivate init(parts: Array<Part>) {
    self.store = parts
  }
  
  public init(from url: URL) {
    self.store = [Part.raw(url.path)]
  }
  
  public init(from components: URLComponents) {
    self.store = [Part.raw(components.path)]
  }
  
  public var parameters: Parameters {
    .init(store.compactMap {
      switch $0 {
      case let .parameter(param): return param
      case .raw: return nil }
    })
  }

  public mutating func append(_ other: URLPath) {
    store.append(contentsOf: other.store)
  }
  
  public func appending(_ other: URLPath) -> URLPath{
    var copy = self
    copy.store.append(contentsOf: other.store)
    return copy
  }
  
  public func resolve(using parameters: Parameters? = nil) -> Result<String, URLError> {
    let parameters = parameters ?? self.parameters
    do {
      return try .success(
        store
        .map { (part: Part) throws -> String in
          switch part {
          case let .raw(string):
            return string
            .split(separator: "/")
            .reduce(into: "", { $0.append("/\($1)") })
          case let .parameter(parameter):
            guard let value = parameters.anyValue(for: parameter)
            else { throw URLError.missingParameter(parameter.name) }
            guard parameters.isValid(parameter.name)
            else { throw URLError.invalidParameter(parameter.name) }
            return "/\(value)"
          }
        }
        .reduce(into: "", { $0.append($1) })
      )
    } catch let error as URLError {
      return .failure(error)
    } catch { fatalError("Never") }
  }
}

extension URLPath.Part: ExpressibleByStringLiteral {
  public init(stringLiteral: StaticString) {
    self = .raw(stringLiteral.string)
  }
}

extension URLPath: ExpressibleByStringLiteral {
  public init(stringLiteral: StaticString) {
    self.init(parts: [.raw(stringLiteral.string)])
  }
}

extension URLPath: ExpressibleByArrayLiteral {
  public init(arrayLiteral parts: URLPath.Part...) {
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
  public static func buildBlock(_ parameters: URLPath.Part...) -> URLPath {
    .init(parts: parameters.map { $0 } )
  }
}

// MARK: - free func

public func param<T>(
  _ name: ParameterName,
  of type: T.Type = T.self,
  value: T? = nil,
  default: T? = nil
) -> URLPath.Part {
  .parameter(Parameter(name, of: type, value: value, default: `default`))
}

public func param<T>(
  _ value: T,
  for name: ParameterName
) -> URLPath.Part {
  .parameter(Parameter(name, of: T.self, value: value))
}

// MARK: - operator

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T,
  default: T
  )
) -> URLPath.Part {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.3))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T
  )
) -> URLPath.Part {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  default: T
  )
) -> URLPath.Part {
  .parameter(Parameter(tuple.0, of: tuple.1, default: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T,
  default: T
  )
) -> URLPath.Part {
  .parameter(Parameter(tuple.0, of: T.self, value: tuple.1, default: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T
  )
) -> URLPath.Part {
  .parameter(Parameter(tuple.0, of: T.self, value: tuple.1))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  default: T
  )
) -> URLPath.Part {
  .parameter(Parameter(tuple.0, of: T.self, default: tuple.1))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type
  )
) -> URLPath.Part {
  .parameter(Parameter(tuple.0, of: tuple.1))
}

public prefix func %<T>(
  _ tuple: (
  T,
  for: ParameterName
  )
) -> URLPath.Part {
  .parameter(Parameter(tuple.1, of: T.self, value: tuple.0))
}
