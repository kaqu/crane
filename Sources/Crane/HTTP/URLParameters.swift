/// Structured set of url parameters.
/// - note: Parameter names are case sensitive.
public struct URLParameters {

  private var store: [URLParameter] = .init()

  /// Set a parameter. It will replace previous one for the same name if any.
  /// - note: Parameter names are case sensitive.
  /// - parameter parameter: Parameter to be set.
  public mutating func set(_ parameter: URLParameter) {
    if let updateIndex = store.firstIndex(where: { $0.name == parameter.name }) {
      store[updateIndex] = parameter
    } else {
      store.append(parameter)
    }
  }

  /// - note: Parameter names are case sensitive.
  public subscript(name: String) -> String? {
    get {
      store.first(where: { $0.name == name })?.value
    }
    set {
      if let value = newValue {
        set(URLParameter(name, value: value))
      } else {
        store.removeAll(where: { $0.name == name })
      }
    }
  }

  /// Get a new instance of parameters set that is a union of this one and provided other set.
  /// In case of conflicts values from provided other set will be used.
  /// - note: Parameter names are case sensitive.
  /// - parameter other: Other set used to make a union.
  /// - returns: New set that is result of updating with other set.
  public func updated(with other: URLParameters) -> URLParameters {
    var result: URLParameters = self
    other.store.forEach { parameter in
      if let updateIndex = store.firstIndex(where: { $0.name == parameter.name }) {
        result.store[updateIndex] = parameter
      } else {
        result.store.append(parameter)
      }
    }
    return result
  }
}

extension URLParameters: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral: (String, String)...) {
    dictionaryLiteral.map(URLParameter.init).forEach { parameter in
      if let updateIndex = store.firstIndex(where: { $0.name == parameter.name }) {
        store[updateIndex] = parameter
      } else {
        store.append(parameter)
      }
    }
  }
}

extension URLParameters: ExpressibleByArrayLiteral {
  public init(arrayLiteral: URLParameter...) {
    arrayLiteral.forEach { parameter in
      if let updateIndex = store.firstIndex(where: { $0.name == parameter.name }) {
        store[updateIndex] = parameter
      } else {
        store.append(parameter)
      }
    }
  }
}
