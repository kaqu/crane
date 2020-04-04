import CraneParameters

public struct URLQuery {

  public typealias Item = (name: String, value: StringOrParameter)

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
    switch parameters.map(self.parameters.updated(with:)) ?? .success(self.parameters) {
    case let .success(parameters):
      do {
        return try .success(
          items
          .compactMap { (item: Item) throws -> String? in
            guard let name = item.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else { throw URLError.invalidEncoding }
            switch item.value {
            case let .string(value):
              guard let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
              else { throw URLError.invalidEncoding }
              return "\(name)=\(value)&"
            case let .parameter(parameter):
              switch parameters.validate(parameter.name) {
              case .success:
                guard let rawValue = parameters.stringValue(for: parameter) else { return nil }
                guard let value = rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                else { throw URLError.invalidEncoding }
                return "\(name)=\(value)&"
              case let .failure(validationError):
                throw URLError.parameterError(.invalid(parameter.name, error: validationError))
              }
            }
          }
          .reduce(into: "", { $0.append($1) })
          // TODO: check if last `&` is allowed
        )
      } catch let error as URLError {
        return .failure(error)
      } catch { fatalError("Never") }
    case let .failure(error):
      return .failure(URLError.parameterError(error))
    }
  }
}

extension URLQuery: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral: (String, StringOrParameter)...) {
    self.items = .init(dictionaryLiteral.map { (name: $0, value: $1) })
  }
}

extension URLQuery: ExpressibleByArrayLiteral {
  public init(arrayLiteral: Item...) {
    self.items = .init(arrayLiteral)
  }
}
