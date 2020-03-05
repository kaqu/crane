import Foundation
import CraneParameters

public struct URLQuery {

  public enum Item: Hashable {
    
    case item(String, value: String)
    case parameter(AnyParameter)
    
    fileprivate var name: String {
      switch self {
      case let .item(name, _):
        return name
      case let .parameter(parameter):
        return parameter.name
      }
    }
    
    fileprivate var value: String? {
      switch self {
      case let .item(_, value):
        return value
      case let .parameter(parameter):
        return parameter.getAny().map(String.init(describing:))
      }
    }
    
    public static func == (lhs: URLQuery.Item, rhs: URLQuery.Item) -> Bool {
      lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(name)
    }
  }

  private var store: Set<Item> = .init()
  
  public var parameters: Parameters {
    .init(store.compactMap {
      switch $0 {
      case let .parameter(param): return param
      case .item: return nil
      }
    })
  }

  public func updated(with other: URLQuery) -> URLQuery {
    var copy = self
    copy.update(with: other)
    return copy
  }
  
  public mutating func update(with other: URLQuery) {
    other.store.forEach { store.update(with: $0) }
  }
  
  
  public func resolve(using parameters: Parameters? = nil) -> Result<String, URLError> {
    let parameters = parameters ?? self.parameters
    fatalError()
  }
}

extension URLQuery: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral: (String, String)...) {
    self.store = .init(dictionaryLiteral.map { .item($0, value: $1) })
  }
}

extension URLQuery: ExpressibleByArrayLiteral {
  public init(arrayLiteral: Item...) {
    self.store = .init(arrayLiteral)
  }
}

// MARK: - free func

public func param<T>(
  _ name: ParameterName,
  of type: T.Type = T.self,
  value: T? = nil,
  default: T? = nil
) -> URLQuery.Item {
  .parameter(Parameter(name, of: type, value: value, default: `default`))
}

public func param<T>(
  _ value: T,
  for name: ParameterName
) -> URLQuery.Item {
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
) -> URLQuery.Item {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.3))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T
  )
) -> URLQuery.Item {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  default: T
  )
) -> URLQuery.Item {
  .parameter(Parameter(tuple.0, of: tuple.1, default: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T,
  default: T
  )
) -> URLQuery.Item {
  .parameter(Parameter(tuple.0, of: T.self, value: tuple.1, default: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T
  )
) -> URLQuery.Item {
  .parameter(Parameter(tuple.0, of: T.self, value: tuple.1))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  default: T
  )
) -> URLQuery.Item {
  .parameter(Parameter(tuple.0, of: T.self, default: tuple.1))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type
  )
) -> URLQuery.Item {
  .parameter(Parameter(tuple.0, of: tuple.1))
}

public prefix func %<T>(
  _ tuple: (
  T,
  for: ParameterName
  )
) -> URLQuery.Item {
  .parameter(Parameter(tuple.1, of: T.self, value: tuple.0))
}
