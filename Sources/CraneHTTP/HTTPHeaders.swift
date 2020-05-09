public struct HTTPHeaders {

  public typealias Header = (name: String, value: StringOrParameter)

  private var headers: Array<Header> = .init()
  
  public init(dict: Dictionary<String, String>) {
    self.headers = dict.map { (name: $0, value: .string($1)) }
  }
  
  public init(_ headers: Array<Header>) {
    self.headers = headers
  }
  
  public var parameters: Parameters {
    .init(headers.compactMap { $0.value.parameter })
  }

  public func updated(with other: HTTPHeaders) -> HTTPHeaders {
    var copy = self
    copy.update(with: other)
    return copy
  }
  
  public mutating func update(with other: HTTPHeaders) {
    other.headers.forEach { item in // TODO: headers are not acctually set...
      if let idx = headers.firstIndex(where: { $0.name == item.name }) {
        headers[idx] = item
      } else {
        headers.append(item)
      }
    }
  }
  
  public func resolve(using parameters: Parameters? = nil) -> Result<Dictionary<String, String>, HTTPError> {
    switch parameters.map(self.parameters.updated(with:)) ?? .success(self.parameters) {
    case let .success(parameters):
      do {
        return try .success(Dictionary<String, String>(uniqueKeysWithValues:
          headers.compactMap { (header: Header) throws -> (key: String, value: String)? in
            switch header.value {
            case let .string(value):
              return (key: header.name, value: value)
            case let .parameter(parameter):
              switch parameters.validate(parameter.name) {
              case .success:
                return parameters.stringValue(for: parameter).map { (key: header.name, value: $0) }
              case let .failure(validationError):
                throw HTTPError.parameterError(.invalid(parameter.name, error: validationError))
              }
            }
          }
        ))
      } catch let error as HTTPError {
        return .failure(error)
      } catch { fatalError("Never") }
    case let .failure(error):
      return .failure(HTTPError.parameterError(error))
    }
  }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral: (String, StringOrParameter)...) {
    self.headers = .init(dictionaryLiteral.map { (name: $0, value: $1) })
  }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
  public init(arrayLiteral: Header...) {
    self.headers = .init(arrayLiteral)
  }
}

public protocol HTTPHeaderValue {
  var httpHeaderValue: String { get }
}

extension URLPathComponent where Self: LosslessStringConvertible {
  public var urlPathComponent: String {
    guard
      !description.contains("/"),
      let encoded = description.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
      else { fatalError("Cannot encode \"\(description)\" as http header value") }
    return encoded
  }
}
extension Bool: URLPathComponent {}
extension String: URLPathComponent {}
extension Substring: URLPathComponent {}
extension UInt: URLPathComponent {}
extension Int: URLPathComponent {}
extension Float: URLPathComponent {}
extension Double: URLPathComponent {}
