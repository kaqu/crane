import CraneParameters

public struct URLQuery {

  public typealias Item = (name: String, value: ValueOrParameter)

  private var items: Array<Item> = .init()
  
  public var parameters: Parameters {
    .init(items.compactMap { $0.value.parameter })
  }

  public func updated(with other: URLQuery) -> URLQuery {
    var copy = self
    copy.update(with: other)
    return copy
  }
  
  public mutating func update(with other: URLQuery) {
    other.items.forEach { item in
      if let idx = items.firstIndex(where: { $0.name == item.name }) {
        items[idx] = item
      } else {
        items.append(item)
      }
    }
  }
  
  public func resolve(using parameters: Parameters? = nil) -> Result<String, URLError> {
    let parameters = parameters.map(self.parameters.updated(with:)) ?? self.parameters
    do {
      return try .success(
        items
        .compactMap { (item: Item) throws -> String? in
          guard let name = item.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
          else { throw URLError.invalidEncoding }
          switch item.value {
          case let .value(value):
            guard let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else { throw URLError.invalidEncoding }
            return "\(name)=\(value)&"
          case let .parameter(parameter):
            if let stringValue = parameters.stringValue(for: parameter) {
              guard parameters.isValid(parameter.name)
              else { throw URLError.invalidParameter(parameter.name, error: nil) }
              guard let value = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
              else { throw URLError.invalidEncoding }
              return "\(name)=\(value)&"
            } else if parameters.isOptional(parameter.name) {
              return nil
            } else {
              throw URLError.missingParameter(parameter.name)
            }
          }
        }
        .reduce(into: "", { $0.append($1) })
        // TODO: check if last `&` is allowed
      )
    } catch let error as URLError {
      return .failure(error)
    } catch { fatalError("Never") }
  }
}

extension URLQuery: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral: (String, ValueOrParameter)...) {
    self.items = .init(dictionaryLiteral.map { (name: $0, value: $1) })
  }
}

extension URLQuery: ExpressibleByArrayLiteral {
  public init(arrayLiteral: Item...) {
    self.items = .init(arrayLiteral)
  }
}
