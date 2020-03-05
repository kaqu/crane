// MARK: - parameter

public typealias ParameterName = String

public protocol AnyParameter {
  var name: ParameterName { get }
  var type: Any.Type { get }
  var isOptional: Bool { get }
  var isValid: Bool { get }
  func get<T>(_ type: T.Type) -> T?
  func getAny() -> Any?
  mutating func set<T>(_ value: T)
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
  
  public func get<T>(_ type: T.Type = T.self) -> T? {
    assert(
      T.self == Value.self,
      "Value type `\(T.self)` is not matching parameter \"\(name)\" of `\(Value.self)`"
    )
    guard let value = value else { return nil }
    return value as? T // At this place T have to be same as Value
  }
  
  public func getAny() -> Any? { value }
  
  public mutating func set<T>(_ value: T) {
    guard let value = value as? Value
      else {
        return assertionFailure(
          "Value type `\(T.self)` is not matching parameter \"\(name)\" of `\(Value.self)`"
        )
    }
    self.value = value
  }
  
  public var isOptional: Bool { (Value.self as? AnyOptional.Type) != nil }
  public var isValid: Bool { isOptional || value != nil } // TODO: allow custom validators
}

// MARK: - parameters
public struct Parameters {
  
  private var parameters: Array<AnyParameter> = .init()
  
  public init() {}
  
  public init(_ parameters: Array<AnyParameter>) {
    self.parameters = parameters
  }
  
  public var isValid: Bool {
    parameters.reduce(into: true, { result, parameter in
      result = result && parameter.isValid
    })
  }
  
  public func isValid(_ parameter: AnyParameter) -> Bool {
    isValid(parameter.name)
  }
  
  public func isValid(_ parameterName: ParameterName) -> Bool {
    parameters.first(where: { $0.name == parameterName })?.isValid ?? false
  }
}

// MARK: - access

public extension Parameters {
  func value<Value>(for parameter: Parameter<Value>) -> Value? {
    value(of: Value.self, for: parameter.name)
  }
  
  func value<Value>(for parameter: AnyParameter) -> Value? {
    value(of: Value.self, for: parameter.name)
  }
  
  func value<Value>(of type: Value.Type = Value.self, for name: ParameterName) -> Value? {
    parameters.first(where: { $0.name == name })?.get(type)
  }
  
  func anyValue(for parameter: AnyParameter) -> Any? {
    guard let storedParameter = parameters.first(where: { $0.name == parameter.name })
    else { return nil }
    assert(
      parameter.type == storedParameter.type,
      "Value type `\(parameter.type)` is not matching parameter \"\(storedParameter.name)\" of `\(storedParameter.type)`"
    )
    return storedParameter.getAny()
  }
  
  subscript<Value>(_ parameter: Parameter<Value>) -> Value? {
    get {
      value(for: parameter)
    }
    set {
      set(value: newValue as Any, for: parameter)
    }
  }
  
  subscript<Value>(_ parameter: AnyParameter) -> Value? {
    get {
      value(for: parameter)
    }
    set {
      set(value: newValue as Any, for: parameter)
    }
  }
  
  subscript<Value>(_ parameterName: ParameterName) -> Value? {
    get {
      value(for: parameterName)
    }
    set {
      set(value: newValue as Any, for: parameterName)
    }
  }
}

// MARK: - update

public extension Parameters {
  mutating func update(from parameters: Parameters) {
    parameters.parameters.forEach { self.insert($0) }
  }
  
  mutating func update(parameter: AnyParameter) { // function builder fails to catch that
    insert(parameter)
  }
  
  mutating func update(@ParametersBuilder _ parametersBuilder: () -> Parameters) {
    update(from: parametersBuilder())
  }
  
  func updated(with parameters: Parameters) -> Parameters {
    var copy = self
    parameters.parameters.forEach { copy.insert($0) }
    return copy
  }
  
  func updated(with parameter: AnyParameter) -> Parameters { // function builder fails to catch that
    var copy = self
    copy.insert(parameter)
    return copy
  }
  
  func updated(@ParametersBuilder _ parametersBuilder: () -> Parameters) -> Parameters {
    updated(with: parametersBuilder())
  }
  
  mutating func insert(_ parameter: AnyParameter) {
    if let index = parameters.firstIndex(where: { $0.name == parameter.name }) {
      parameters[index] = parameter
    } else {
      parameters.append(parameter)
    }
  }
  
  mutating func insert<Value>(_ value: Value, for parameter: Parameter<Value>) {
    var parameter = parameter
    parameter.set(value)
    insert(parameter)
  }
  
  mutating func insert(_ value: Any, for parameter: AnyParameter) {
    var parameter = parameter
    parameter.set(value)
    insert(parameter)
  }
  
  mutating func insert<Value>(_ value: Value, for name: ParameterName) {
    insert(Parameter(name, value: value))
  }
  
  mutating func remove(_ parameter: AnyParameter) {
    remove(parameter.name)
  }
  
  mutating func remove(_ name: ParameterName) {
    guard let currentIndex = parameters.firstIndex(where: { $0.name == name }) else { return }
    parameters.remove(at: currentIndex)
  }
  
  mutating func set<Value>(value: Value, for parameter: Parameter<Value>) {
    set(value: value, for: parameter.name)
  }
  
  mutating func set(value: Any, for parameter: AnyParameter) {
    set(value: value, for: parameter.name)
  }
  
  mutating func set<Value>(value: Value?, for name: ParameterName) {
    guard let index = parameters.firstIndex(where: { $0.name == name })
      else { return assertionFailure("Trying to set not required parameter value") }
    parameters[index].set(value)
  }
}
// MARK: - init

public extension Parameters {
  
  init(_ parameter: AnyParameter) { // function builder fails to catch that
    self.init([parameter])
  }
  
  init(@ParametersBuilder _ parametersBuilder: () -> Parameters) {
    self = parametersBuilder()
  }
  
  init(_ parameters: AnyParameter...) {
    self.init(parameters.map { $0 })
  }
}

extension Parameters: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: AnyParameter...) {
    self.init(elements.map { $0 })
  }
}

// MARK: - builder

@_functionBuilder
public enum ParametersBuilder {
  
  public static func buildBlock(_ parameters: AnyParameter...) -> Parameters {
    .init(parameters.map { $0 } )
  }
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
