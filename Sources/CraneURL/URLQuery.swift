import struct Foundation.NSURL.URLQueryItem

public struct URLQuery {
  
  public private(set) var items: Set<URLQueryItem> = .init()
  
  public init(_ items: URLQueryItem...) {
    self.items = Set(items)
  }
  
  public var queryString: String? {
    guard !items.isEmpty else { return nil }
    return items.reduce(into: "" as String) { result, item in
      guard
        let value = item.value?
          .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
      else { return assertionFailure("Cannot encode \"\(String(describing: item.value))\" as url query value") }
      defer { result.append("\(item.name)=\(value)") }
      guard !result.isEmpty else { return }
      result.append("&")
    }
  }
}

public extension URLQuery {
  subscript<Value: URLQueryValue>(_ name: String) -> Value? {
    get { items.first(where: { $0.name == name })?.value.flatMap(Value.init) }
    set {
      _ = newValue
        .map { items.update(with: URLQueryItem(name: name, value: $0.urlQueryValue)) }
        ?? items.firstIndex(where: { $0.name == name }).map { items.remove(at: $0) }
    }
  }
}

extension URLQuery: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral: (String, URLQueryValue)...) {
    self.items = .init(dictionaryLiteral.map { URLQueryItem(name: $0, value: $1.urlQueryValue) })
  }
}

extension URLQuery: ExpressibleByArrayLiteral {
  public init(arrayLiteral: URLQueryItem...) {
    self.items = .init(arrayLiteral)
  }
}

extension URLQuery: CustomStringConvertible {
  public var description: String { queryString ?? "" }
}

public protocol URLQueryValue {
  init?(urlQueryValue: String)
  var urlQueryValue: String { get }
}

extension URLQueryValue where Self: LosslessStringConvertible {
  
  public init?(urlQueryValue: String) {
    self.init(urlQueryValue)
  }
  
  public var urlQueryValue: String { description }
}

extension Bool: URLQueryValue {}
extension String: URLQueryValue {}
extension Substring: URLQueryValue {}
extension UInt: URLQueryValue {}
extension Int: URLQueryValue {}
extension Float: URLQueryValue {}
extension Double: URLQueryValue {}

