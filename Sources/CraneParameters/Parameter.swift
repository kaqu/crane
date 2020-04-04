public typealias ParameterName = String

public protocol AnyParameter {
  var name: ParameterName { get }
  var type: Any.Type { get }
  var isOptional: Bool { get }
  var stringValue: String? { get }
  func validate() -> Result<Void, Error>
  func get<T>(_ type: T.Type, allowInvalid: Bool) -> Result<T, ParameterError>
  @discardableResult mutating func set<T>(_ value: T) -> Result<Void, ParameterError>
  @discardableResult mutating func update(using other: AnyParameter) -> Result<Void, ParameterError>
}

public extension AnyParameter {
  var isValid: Bool {
    switch validate() {
    case .success: return true
    case .failure: return false
    }
  }
}

public struct Parameter<Value>: AnyParameter {
  public let name: ParameterName
  public var type: Any.Type { Value.self }
  public var isOptional: Bool { (Value.self as? AnyOptional.Type) != nil }
  public var validator: ((Value) -> Result<Void, Error>)?
  public var stringValue: String? {
    guard isValid else { return nil }
    return nonOptionalStringValue(of: value as Any)
  }
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
    default: Value? = nil,
    validator: ((Value) -> Result<Void, Error>)? = nil
  ) {
    self.name = name
    self.defaultValue = `default`
    self._value = value
    self.validator = validator
  }
  
  public init(
    _ name: ParameterName,
    of: Value.Type = Value.self,
    value: Value? = nil,
    default: Value? = nil,
    validator: ((Value) -> Bool)? = nil
  ) {
    self.name = name
    self.defaultValue = `default`
    self._value = value
    self.validator = validator.map(genericParameterValidator)
  }
  
  public init(_ tuple: (Value, for: ParameterName)) {
    self.init(tuple.1, value: tuple.0, validator: Optional<(Value) -> Bool>.none)
  }
  
  public init(_ tuple: (ParameterName, Value)) {
    self.init(tuple.0, value: tuple.1, validator: Optional<(Value) -> Bool>.none)
  }
  
  public init(_ tuple: (ParameterName, of: Value.Type)) {
    self.init(tuple.0, of: tuple.1, validator: Optional<(Value) -> Bool>.none)
  }
  
  public init(_ tuple: (ParameterName, of: Value.Type, default: Value)) {
    self.init(tuple.0, of: tuple.1, default: tuple.2, validator: Optional<(Value) -> Bool>.none)
  }
  
  public init(_ tuple: (ParameterName, of: Value.Type, default: Value, validator: (Value) -> Result<Void, Error>)) {
    self.init(tuple.0, of: tuple.1, default: tuple.2, validator: tuple.3)
  }
  
  public init(_ tuple: (ParameterName, of: Value.Type, default: Value, validator: (Value) -> Bool)) {
    self.init(tuple.0, of: tuple.1, default: tuple.2, validator: tuple.3)
  }
  
  public func validate() -> Result<Void, Error> {
    validate(value)
  }
  
  private func validate(_ value: Value?) -> Result<Void, Error> {
    switch value {
    case let .some(value):
      return validator?(value) ?? .success(())
    case .none:
      return isOptional
        ? .success(())
        : .failure(ParameterValidationError.missing)
    }
  }
  
  public func get<T>(_ type: T.Type = T.self, allowInvalid: Bool = false) -> Result<T, ParameterError> {
    guard type != Any.self else {
      return .success(value as! T) // cast to Any always succeeds
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
      else { return .failure(.wrongType(T.self, for: name, expected: Value.self)) }
    switch validate() {
    case .success:
      guard let value = value as? T else { fatalError("Never") }
      return .success(value) // at this point it has to be valid and have correct type but have to flatten optionals if any
    case let .failure(validationError):
      if value != nil, allowInvalid {
        return .success(value as! T) // at this point it has to  have correct type
      } else if value == nil, isOptional, allowInvalid {
        return .success(value as! T) //  at this point it is null and type is optional
      } else if value == nil, !isOptional {
        return .failure(.missing(name))
      } else {
        return .failure(.invalid(name, error: validationError))
      }
    }
  }

  @discardableResult public mutating func set<T>(_ value: T) -> Result<Void, ParameterError> {
    guard let value = value as? Value
      else {
        assertionFailure(
          "Value type `\(T.self)` is not matching parameter \"\(name)\" of `\(Value.self)`"
        )
        return .failure(.wrongType(T.self, for: name, expected: Value.self))
    }
    self.value = value
    return .success(())
  }
  
  @discardableResult public mutating func update(using other: AnyParameter) -> Result<Void, ParameterError> {
    other.get(Value.self, allowInvalid: true).flatMap { self.set($0) }
  }
}

// MARK: - free func
public func param<T>(
  _ name: ParameterName,
  of type: T.Type = T.self,
  value: T? = nil,
  default: T? = nil,
  validator: ((T) -> Result<Void, Error>)? = nil
) -> AnyParameter {
  Parameter(
    name,
    of: type,
    value: value,
    default: `default`,
    validator: validator
  )
}

public func param<T>(
  _ name: ParameterName,
  of type: T.Type = T.self,
  value: T? = nil,
  default: T? = nil,
  validator: ((T) -> Bool)? = nil
) -> AnyParameter {
  Parameter(
    name,
    of: type,
    value: value,
    default: `default`,
    validator: validator.map(genericParameterValidator)
  )
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
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.3, validator: tuple.4)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T,
  default: T,
  validator: (T) -> Bool
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.3, validator: genericParameterValidator(tuple.4))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T,
  default: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.3, validator: Optional<(T) -> Bool>.none)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T,
  validator: ((T) -> Result<Void, Error>)
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, value: tuple.2, validator: tuple.3)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T,
  validator: (T) -> Bool
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, value: tuple.2, validator: genericParameterValidator(tuple.3))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  default: T,
  validator: ((T) -> Result<Void, Error>)
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.2, validator: tuple.3)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  default: T,
  validator: (T) -> Bool
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, value: tuple.2, default: tuple.2, validator: genericParameterValidator(tuple.3))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  value: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, value: tuple.2, validator: Optional<(T) -> Bool>.none)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  default: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, default: tuple.2, validator: Optional<(T) -> Bool>.none)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  validator: ((T) -> Result<Void, Error>)
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, validator: tuple.2)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type,
  validator: (T) -> Bool
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, validator: genericParameterValidator(tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T,
  validator: ((T) -> Result<Void, Error>)
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, value: tuple.1, validator: tuple.2)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T,
  validator: (T) -> Bool
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, value: tuple.1, validator: genericParameterValidator(tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  default: T,
  validator: ((T) -> Result<Void, Error>)
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, default: tuple.1, validator: tuple.2)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  default: T,
  validator: (T) -> Bool
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, default: tuple.1, validator: genericParameterValidator(tuple.2))
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T,
  default: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, value: tuple.1, default: tuple.2, validator: Optional<(T) -> Bool>.none)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  value: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, value: tuple.1, validator: Optional<(T) -> Bool>.none)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  default: T
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, default: tuple.1, validator: Optional<(T) -> Bool>.none)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  of: T.Type
  )
) -> AnyParameter {
  Parameter(tuple.0, of: tuple.1, validator: Optional<(T) -> Bool>.none)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  validator: ((T) -> Result<Void, Error>)
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, validator: tuple.1)
}

public prefix func %<T>(
  _ tuple: (
  ParameterName,
  validator: (T) -> Bool
  )
) -> AnyParameter {
  Parameter(tuple.0, of: T.self, validator: genericParameterValidator(tuple.1))
}

public prefix func %<T>(
  _ tuple: (
  T,
  for: ParameterName
  )
) -> AnyParameter {
  Parameter(tuple.1, of: T.self, value: tuple.0, validator: Optional<(T) -> Bool>.none)
}

internal func genericParameterValidator<T>(_ validator: @escaping (T) -> Bool) -> (T) -> Result<Void, Error> {
  { (value: T) -> Result<Void, Error> in
    validator(value) ? .success(()) : .failure(ParameterValidationError.invalid)
  }
}
