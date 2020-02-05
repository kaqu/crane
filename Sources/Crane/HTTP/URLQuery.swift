import Foundation

/// Structured set of url query items.
/// - note: Query item names are case sensitive.
public struct URLQuery {

  /// All stored query items.
  public var allItems: [URLQueryItem] { store }
  public var isEmpty: Bool { store.isEmpty }

  private var store: [URLQueryItem] = .init()

  /// Set a query item. It will replace previous one for the same name if any.
  /// - parameter queryItem: Query item to be set.
  public mutating func set(_ queryItem: URLQueryItem) {
    if let updateIndex = store.firstIndex(where: { $0.name == queryItem.name }) {
      store[updateIndex] = queryItem
    } else {
      store.append(queryItem)
    }
  }

  public subscript(itemName: String) -> String? {
    get {
      store.first(where: { $0.name == itemName })?.value
    }
    set {
      if let value = newValue {
        set(URLQueryItem(name: itemName, value: value))
      } else {
        store.removeAll(where: { $0.name == itemName })
      }
    }
  }

  /// Get a new instance of query items set that is a union of this one and provided other set.
  /// In case of conflicts values from provided other set will be used.
  /// - parameter other: other set used to make a union
  /// - returns: new set that is result of updating with other set
  public func updated(with other: URLQuery) -> URLQuery {
    var result: URLQuery = self
    other.store.forEach { queryItem in
      if let updateIndex = store.firstIndex(where: { $0.name == queryItem.name }) {
        result.store[updateIndex] = queryItem
      } else {
        result.store.append(queryItem)
      }
    }
    return result
  }
}

extension URLQuery: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral: (String, String)...) {
    dictionaryLiteral.map(URLQueryItem.init).forEach { queryItem in
      if let updateIndex = store.firstIndex(where: { $0.name == queryItem.name }) {
        store[updateIndex] = queryItem
      } else {
        store.append(queryItem)
      }
    }
  }
}

extension URLQuery: ExpressibleByArrayLiteral {
  public init(arrayLiteral: URLQueryItem...) {
    arrayLiteral.forEach { queryItem in
      if let updateIndex = store.firstIndex(where: { $0.name == queryItem.name }) {
        store[updateIndex] = queryItem
      } else {
        store.append(queryItem)
      }
    }
  }
}
