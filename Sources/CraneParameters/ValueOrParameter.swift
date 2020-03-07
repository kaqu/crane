public enum ValueOrParameter {

  case value(String)
  case parameter(AnyParameter)

  public static func value(of any: Any) -> ValueOrParameter {
    .value(String(describing: any))
  }
  
  public var parameter: AnyParameter? {
    switch self {
    case .value:
      return nil
    case let .parameter(param):
      return param
    }
  }
  
  public func value(using parameter: AnyParameter? = nil) -> String? {
    switch self {
    case let .value(value):
      return value
    case let .parameter(param):
      return (parameter?.getAny() ?? param.getAny()).map(String.init(describing:))
    }
  }
  
  public func value(using parameters: Parameters? = nil) -> String? {
    switch self {
    case let .value(value):
      return value
    case let .parameter(param):
      guard let parameters = parameters
      else {
        return param.getAny().map(String.init(describing:))
      }
      return parameters.anyValue(for: param).map(String.init(describing:))
    }
  }
}

// MARK: - literal

extension ValueOrParameter: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    self = .value(stringLiteral)
  }
}

extension ValueOrParameter: ExpressibleByIntegerLiteral {
  public init(integerLiteral: Int) {
    self = .value(String(describing: integerLiteral))
  }
}

extension ValueOrParameter: ExpressibleByFloatLiteral {
  public init(floatLiteral: Double) {
    self = .value(String(describing: floatLiteral))
  }
}

extension ValueOrParameter: ExpressibleByBooleanLiteral {
  public init(booleanLiteral: Bool) {
    self = .value(String(describing: booleanLiteral))
  }
}

// MARK: - free func

public func param<T>(
  _ name: ParameterName,
  of type: T.Type = T.self,
  value: T? = nil,
  default: T? = nil
) -> ValueOrParameter {
  .parameter(Parameter(name, of: type, value: value, default: `default`))
}

public func param<T>(
  _ value: T,
  for name: ParameterName
) -> ValueOrParameter {
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
) -> ValueOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.3))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T
  )
) -> ValueOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  default: T
  )
) -> ValueOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, default: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T,
  default: T
  )
) -> ValueOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, value: tuple.1, default: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T
  )
) -> ValueOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, value: tuple.1))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  default: T
  )
) -> ValueOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, default: tuple.1))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type
  )
) -> ValueOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1))
}

public prefix func %<T>(
  _ tuple: (
  T,
  for: ParameterName
  )
) -> ValueOrParameter {
  .parameter(Parameter(tuple.1, of: T.self, value: tuple.0))
}
