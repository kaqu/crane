public typealias ParameterName = String

public protocol AnyParameter {
  var name: ParameterName { get }
  var type: Any.Type { get }
  var isOptional: Bool { get }
  var isValid: Bool { get }
  func get<T>(_ type: T.Type) -> Result<T, ParameterError>
  @discardableResult mutating func set<T>(_ value: T) -> Result<Void, ParameterError>
}

public extension AnyParameter {
  var stringValue: String? {
    guard isValid else { return nil }
    switch get(Any.self) {
    case let .success(value):
      guard let optional = value as? AnyOptional
      else { return String(describing: value) }
      return optional.string
    case .failure:
      return nil
    }
  }
}

public struct Parameter<Value>: AnyParameter {
  public let name: ParameterName
  public var type: Any.Type { Value.self }
  public var defaultValue: Value?
  public var value: Value? {
    get { _value ?? defaultValue }
    set { _value = newValue }
  }
  private var _value: Value?
  
  public init(
    _ name: ParameterName,
    of: Value.Type = Value.self,
    value: Value? = nil,
    default: Value? = nil
  ) {
    self.name = name
    self.defaultValue = `default`
    self._value = value
  }
  
  public init(_ tuple: (Value, for: ParameterName)) {
    self.init(tuple.1, value: tuple.0)
  }
  
  public init(_ tuple: (ParameterName, Value)) {
    self.init(tuple.0, value: tuple.1)
  }
  
  public init(_ tuple: (ParameterName, of: Value.Type)) {
    self.init(tuple.0, of: tuple.1)
  }
  
  public init(_ tuple: (ParameterName, of: Value.Type, default: Value)) {
    self.init(tuple.0, of: tuple.1, default: tuple.2)
  }
  
  public func get<T>(_ type: T.Type = T.self) -> Result<T, ParameterError> {
    guard type != Any.self else {
      return .success(value as! T)
    }
    assert(
      T.self == Value.self
      || (T.self as? AnyOptional.Type)?.wrappedType == Value.self
      || (Value.self as? AnyOptional.Type)?.wrappedType == T.self,
      "Value type `\(T.self)` is not matching parameter \"\(name)\" of `\(Value.self)`"
    )
    guard T.self == Value.self
          || (T.self as? AnyOptional.Type)?.wrappedType == Value.self
          || (Value.self as? AnyOptional.Type)?.wrappedType == T.self
    else { return .failure(.wrongType(name, expected: Value.self)) }
    guard let value = value as? T
    else { return .failure(.missing(name)) }
    guard isValid else { return .failure(.invalid(name, error: nil)) }
    return .success(value)
  }
  
//  public func getAny() -> Any? { value }
  
  @discardableResult public mutating func set<T>(_ value: T) -> Result<Void, ParameterError> {
    guard let value = value as? Value
      else {
        assertionFailure(
          "Value type `\(T.self)` is not matching parameter \"\(name)\" of `\(Value.self)`"
        )
        return .failure(.wrongType(name, expected: Value.self))
    }
    self.value = value
    return .success(())
  }
  
  public var isOptional: Bool { (Value.self as? AnyOptional.Type) != nil }
  public var isValid: Bool { isOptional || value != nil } // TODO: allow custom validators
}

// MARK: - free func

public func param<T>(
  _ name: ParameterName,
  of type: T.Type = T.self,
  value: T? = nil,
  default: T? = nil
) -> AnyParameter {
  Parameter(name, of: type, value: value, default: `default`)
}

public func param<T>(
  _ value: T,
  for name: ParameterName
) -> AnyParameter {
  Parameter(name, of: T.self, value: value)
}

// MARK: - operator

prefix operator %

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T,
  default: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.3)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, value: tuple.2)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  default: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, default: tuple.2)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T,
  default: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, value: tuple.1, default: tuple.2)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, value: tuple.1)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  default: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, default: tuple.1)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1)
}

public prefix func %<T>(
  _ tuple: (
  T,
  for: ParameterName
  )
) -> AnyParameter {
  Parameter(tuple.1, of: T.self, value: tuple.0)
}
