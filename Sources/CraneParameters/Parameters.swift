public struct Parameters {
  
  private var parameters: Array<AnyParameter> = .init()
  
  public init() {}
  
  public init(_ parameters: Array<AnyParameter>) {
    self.parameters = parameters
  }
  
  public var allValid: Bool {
    parameters.reduce(into: true, { result, parameter in
      result = result && parameter.isValid
    })
  }
  
  public func validate(_ parameter: AnyParameter) -> Result<Void, Error> {
    validate(parameter.name)
  }
  
  public func validate(_ parameterName: ParameterName) -> Result<Void, Error> {
    parameters.first(where: { $0.name == parameterName })?.validate() ?? .failure(ParameterError.missing(parameterName))
  }
  
  public func isValid(_ parameter: AnyParameter) -> Bool {
    isValid(parameter.name)
  }
  
  public func isValid(_ parameterName: ParameterName) -> Bool {
    parameters.first(where: { $0.name == parameterName })?.isValid ?? false
  }
  
  public func isOptional(_ parameter: AnyParameter) -> Bool {
    isOptional(parameter.name)
  }
  
  public func isOptional(_ parameterName: ParameterName) -> Bool {
    parameters.first(where: { $0.name == parameterName })?.isOptional ?? true
  }
}

// MARK: - access

public extension Parameters {
  func value<Value>(for parameter: Parameter<Value>) -> Result<Value, ParameterError> {
    value(of: Value.self, for: parameter.name)
    .flatMapError { error in
      if case .missing = error {
        return parameter.get()
      } else {
        return .failure(error)
      }
    }
  }
  
  func value<Value>(
    of type: Value.Type = Value.self,
    for parameter: AnyParameter
  ) -> Result<Value, ParameterError> {
    value(of: Value.self, for: parameter.name)
    .flatMapError { error in
      if case .missing = error {
        return parameter.get(Value.self, allowInvalid: false)
      } else {
        return .failure(error)
      }
    }
  }
  
  func value<Value>(
    of type: Value.Type = Value.self,
    for name: ParameterName
  ) -> Result<Value, ParameterError> {
    parameters
      .first(where: { $0.name == name })
      .map { $0.get(type, allowInvalid: false) }
      ?? .failure(.missing(name))
  }
  
  func stringValue(
    for parameter: AnyParameter
  ) -> String? {
    stringValue(for: parameter.name)
  }
  
  func stringValue(
    for name: ParameterName
  ) -> String? {
    parameters
    .first(where: { $0.name == name })
    .flatMap { $0.stringValue }
  }

  subscript<Value>(_ parameter: Parameter<Value>) -> Value? {
    get {
      switch value(for: parameter) {
      case let .success(value): return value
      case .failure: return nil
      }
    }
    set {
      set(value: newValue as Any, for: parameter)
    }
  }
  
  subscript<Value>(_ parameter: AnyParameter) -> Value? {
    get {
      switch value(of: Value.self, for: parameter) {
      case let .success(value): return value
      case .failure: return nil
      }
    }
    set {
      set(value: newValue as Any, for: parameter)
    }
  }
  
  subscript<Value>(_ parameterName: ParameterName) -> Value? {
    get {
      switch value(of: Value.self, for: parameterName) {
      case let .success(value): return value
      case .failure: return nil
      }
    }
    set {
      set(value: newValue as Any, for: parameterName)
    }
  }
}

// MARK: - update

public extension Parameters {
  mutating func update(with parameters: Parameters) -> Result<Void, ParameterError> {
    let revertCopy = self
    for parameter in parameters.parameters {
      switch update(parameter) {
      case .success:
        continue
      case let .failure(error):
        self = revertCopy
        return .failure(error)
      }
    }
    return .success(())
  }
  
  @discardableResult mutating func update(_ parameter: AnyParameter) -> Result<Void, ParameterError> { // function builder fails to catch that
    if let index = parameters.firstIndex(where: { $0.name == parameter.name }) {
      return parameters[index].update(using: parameter)
    } else {
      parameters.append(parameter)
      return .success(())
    }
  }
  
  mutating func update(@ParametersBuilder _ parametersBuilder: () -> Parameters) -> Result<Void, ParameterError> {
    update(with: parametersBuilder())
  }
  
  func updated(with parameters: Parameters) -> Result<Parameters, ParameterError> {
    var copy = self
    return copy.update(with: parameters).map { _ in copy }
  }
  
  func updated(with parameter: AnyParameter) -> Result<Parameters, ParameterError> { // function builder fails to catch that
    var copy = self
    return copy.update(parameter).map { copy }
  }
  
  func updated(@ParametersBuilder _ parametersBuilder: () -> Parameters) -> Result<Parameters, ParameterError> {
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
    insert(Parameter(name, value: value, validator: Optional<(Value) -> Bool>.none))
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

