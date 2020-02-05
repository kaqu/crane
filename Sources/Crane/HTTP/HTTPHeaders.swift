import Foundation

/// Structured set of http header fields.
/// - note: Header names are case insensitive.
public struct HTTPHeaders {

  /// Raw representation of all sored headers.
  /// - warning: According to RFC2616, RFC7230 and RFC7540 "set-cookie" header might occur more than once.
  /// Getting raw dictionary will not preserve more than once occurence of "set-cookie", random one will be used if any.
  /// - note: Header names are case insensitive but original strings are kept in unchanged form.
  public var rawDictionary: [String: String] { Dictionary(uniqueKeysWithValues: store.map { ($0.name, $0.value) }) }
  /// All stored headers.
  public var allHeaders: [HTTPHeader] { store }
  public var isEmpty: Bool { store.isEmpty }

  private var store: [HTTPHeader] = .init()

  /// Initialize from any dictionary converting all valid values to headers and skippng rest.
  /// - note: Header names are case insensitive.
  public init(from anyDictionary: [AnyHashable: Any]) {
    anyDictionary
    .compactMap { (key: Any, value: Any) -> (String, String)? in
      guard
        let stringKey = key as? String,
        let stringValue = value as? String
      else { return nil }
      return (stringKey, stringValue)
    }
    .map(HTTPHeader.init).forEach { header in
      if
        let updateIndex = store.firstIndex(where: { $0.name.lowercased() == header.name.lowercased() }),
        header.name.lowercased() != "set-cookie"
      {
        store[updateIndex] = header
      } else {
        store.append(header)
      }
    }
  }

  /// Set a header. It will replace previous one for the same name if any.
  /// - parameter header: Heder to be set.
  /// - note: Header names are case insensitive.
  public mutating func set(_ header: HTTPHeader) {
    if
      let updateIndex = store.firstIndex(where: { $0.name.lowercased() == header.name.lowercased() }),
      header.name.lowercased() != "set-cookie"
    {
      store[updateIndex] = header
    } else {
      store.append(header)
    }
  }

  /// - warning: According to RFC2616, RFC7230 and RFC7540 "set-cookie" header might occur more than once.
  /// Getting "set-cookie" header by name will return random one if any.
  /// - note: Header names are case insensitive.
  public subscript(name: String) -> String? {
    get {
      store.first(where: { $0.name.lowercased() == name.lowercased() })?.value
    }
    set {
      if let value = newValue {
        set(HTTPHeader(name, value: value))
      } else {
        store.removeAll(where: { $0.name.lowercased() == name.lowercased() })
      }
    }
  }

  /// Get a new instance of headers set that is a union of this one and provided other set.
  /// In case of conflicts values from provided other set will be used.
  /// - warning: According to RFC2616, RFC7230 and RFC7540 "set-cookie" header might occur more than once.
  /// All values for that header will be used withut duplicate checks.
  /// - note: Header names are case insensitive.
  /// - parameter other: Other set used to make a union.
  /// - returns: New set that is result of updating with other set.
  public func updated(with other: HTTPHeaders) -> HTTPHeaders {
    var result: HTTPHeaders = self
    other.store.forEach { header in
      if
        let updateIndex = store.firstIndex(where: { $0.name.lowercased() == header.name.lowercased() }),
        header.name.lowercased() != "set-cookie"
      {
        result.store[updateIndex] = header
      } else {
        result.store.append(header)
      }
    }
    return result
  }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral: (String, String)...) {
    dictionaryLiteral.map(HTTPHeader.init).forEach { header in
      if
        let updateIndex = store.firstIndex(where: { $0.name.lowercased() == header.name.lowercased() }),
        header.name.lowercased() != "set-cookie"
      {
        store[updateIndex] = header
      } else {
        store.append(header)
      }
    }
  }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
  public init(arrayLiteral: HTTPHeader...) {
    arrayLiteral.forEach { header in
      if
        let updateIndex = store.firstIndex(where: { $0.name.lowercased() == header.name.lowercased() }),
        header.name.lowercased() != "set-cookie"
      {
        store[updateIndex] = header
      } else {
        store.append(header)
      }
    }
  }
}
