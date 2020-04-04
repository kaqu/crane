public enum StringOrParameter {

  case string(String)
  case parameter(AnyParameter)

  public static func value(of any: Any) -> StringOrParameter {
    .string(String(describing: any))
  }
  
  public var parameter: AnyParameter? {
    switch self {
    case .string:
      return nil
    case let .parameter(param):
      return param
    }
  }
}

// MARK: - literal

extension StringOrParameter: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    self = .string(stringLiteral)
  }
}

extension StringOrParameter: ExpressibleByIntegerLiteral {
  public init(integerLiteral: Int) {
    self = .string(String(describing: integerLiteral))
  }
}

extension StringOrParameter: ExpressibleByFloatLiteral {
  public init(floatLiteral: Double) {
    self = .string(String(describing: floatLiteral))
  }
}

extension StringOrParameter: ExpressibleByBooleanLiteral {
  public init(booleanLiteral: Bool) {
    self = .string(String(describing: booleanLiteral))
  }
}

// MARK: - free func

public func param<T>(
  _ name: ParameterName,
  of type: T.Type = T.self,
  value: T? = nil,
  default: T? = nil,
  validator: ((T) -> Result<Void, Error>)? = nil
) -> StringOrParameter {
  .parameter(Parameter(name, of: type, value: value, default: `default`, validator: validator))
}

public func param<T>(
  _ name: ParameterName,
  of type: T.Type = T.self,
  value: T? = nil,
  default: T? = nil,
  validator: ((T) -> Bool)? = nil
) -> StringOrParameter {
  .parameter(Parameter(name, of: type, value: value, default: `default`, validator: validator.map(genericParameterValidator)))
}

// MARK: - operator

prefix operator %

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T,
  default: T,
  validator: ((T) -> Result<Void, Error>)
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.3, validator: tuple.4))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T,
  default: T,
  validator: (T) -> Bool
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.3, validator: genericParameterValidator(tuple.4)))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T,
  default: T
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.3, validator: Optional<(T) -> Bool>.none))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T,
  validator: ((T) -> Result<Void, Error>)
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2, validator: tuple.3))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T,
  validator: (T) -> Bool
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2, validator: genericParameterValidator(tuple.3)))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  default: T,
  validator: ((T) -> Result<Void, Error>)
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.2, validator: tuple.3))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  default: T,
  validator: (T) -> Bool
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.2, validator: genericParameterValidator(tuple.3)))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, value: tuple.2, validator: Optional<(T) -> Bool>.none))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  default: T
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, default: tuple.2, validator: Optional<(T) -> Bool>.none))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  validator: ((T) -> Result<Void, Error>)
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, validator: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  validator: (T) -> Bool
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, validator: genericParameterValidator(tuple.2)))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T,
  validator: ((T) -> Result<Void, Error>)
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, value: tuple.1, validator: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T,
  validator: (T) -> Bool
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, value: tuple.1, validator: genericParameterValidator(tuple.2)))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  default: T,
  validator: ((T) -> Result<Void, Error>)
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, default: tuple.1, validator: tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  default: T,
  validator: (T) -> Bool
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, default: tuple.1, validator: genericParameterValidator(tuple.2)))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T,
  default: T
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, value: tuple.1, default: tuple.2, validator: Optional<(T) -> Bool>.none))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, value: tuple.1, validator: Optional<(T) -> Bool>.none))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  default: T
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, default: tuple.1, validator: Optional<(T) -> Bool>.none))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: tuple.1, validator: Optional<(T) -> Bool>.none))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  validator: ((T) -> Result<Void, Error>)
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, validator: tuple.1))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  validator: (T) -> Bool
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.0, of: T.self, validator: genericParameterValidator(tuple.1)))
}

public prefix func %<T>(
  _ tuple: (
  T,
  for: ParameterName
  )
) -> StringOrParameter {
  .parameter(Parameter(tuple.1, of: T.self, value: tuple.0, validator: Optional<(T) -> Bool>.none))
}
