import CraneParameters

public struct HTTPHeaders {

  public typealias Header = (name: String, value: ValueOrParameter)

  private var headers: Array<Header> = .init()
  
  public init(dict: Dictionary<String, String>) {
    self.headers = dict.map { (name: $0, value: .value($1)) }
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
    let parameters = parameters.map(self.parameters.updated(with:)) ?? self.parameters
    do {
      return try .success(Dictionary<String, String>(uniqueKeysWithValues:
        headers.compactMap { (header: Header) throws -> (key: String, value: String)? in
          let headerValue: String
          switch header.value {
          case let .value(value):
            headerValue = value
          case let .parameter(parameter):
            if let valueString = parameters.stringValue(for: parameter) {
              guard parameters.isValid(parameter.name)
              else { throw HTTPError.invalidParameter(parameter.name, value: valueString) }
              headerValue = valueString
            } else if parameters.isOptional(parameter.name) {
              return nil
            } else {
              throw HTTPError.missingParameter(parameter.name)
            }
          }
          return (key: header.name, value: headerValue)
        }
      ))
    } catch let error as HTTPError {
      return .failure(error)
    } catch { fatalError("Never") }
  }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral: (String, ValueOrParameter)...) {
    self.headers = .init(dictionaryLiteral.map { (name: $0, value: $1) })
  }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
  public init(arrayLiteral: Header...) {
    self.headers = .init(arrayLiteral)
  }
}
