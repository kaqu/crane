public struct HTTPHeaders {
  
  public private(set) var headers: Set<HTTPHeader> = .init()
  
  public init(_ headers: HTTPHeader...) {
    self.headers = Set(headers)
  }
  
  public init(_ dictionary: [String: String]) {
    self.headers = Set(dictionary.map { HTTPHeader(name: $0.key, value: $0.value) })
  }
  
  public var dictionary: [String: String] {
    Dictionary(uniqueKeysWithValues: headers.map { ($0.name, $0.value.httpHeaderValue) })
  }
}

public extension HTTPHeaders {
  subscript<Value: HTTPHeaderValue>(_ name: String) -> Value? {
    get { (headers.first(where: { $0.name == name })?.value).flatMap(Value.init) }
    set {
      _ = newValue.map { headers.update(with: HTTPHeader(name: name, value: $0.httpHeaderValue)) }
        ?? headers.firstIndex(where: { $0.name == name }).map { headers.remove(at: $0) }
    }
  }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral: (String, HTTPHeaderValue)...) {
    self.headers = .init(dictionaryLiteral.map { HTTPHeader(name: $0, value: $1.httpHeaderValue) })
  }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
  public init(arrayLiteral: HTTPHeader...) {
    self.headers = .init(arrayLiteral)
  }
}

extension HTTPHeaders: CustomStringConvertible {
  public var description: String { dictionary.description }
}

public struct HTTPHeader: Hashable {
  public let name: String
  public var value: String
  
  public init(name: String, value: String) {
    self.name = name
    self.value = value
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
  
  public static func ==(_ lhs: HTTPHeader, _ rhs: HTTPHeader) -> Bool {
    lhs.name == rhs.name
  }
}

public protocol HTTPHeaderValue {
  init?(httpHeaderValue: String)
  var httpHeaderValue: String { get }
}

extension HTTPHeaderValue where Self: LosslessStringConvertible {
  
  public init?(httpHeaderValue: String) {
    self.init(httpHeaderValue)
  }
  
  public var httpHeaderValue: String { description }
}

extension Bool: HTTPHeaderValue {}
extension String: HTTPHeaderValue {}
extension Substring: HTTPHeaderValue {}
extension UInt: HTTPHeaderValue {}
extension Int: HTTPHeaderValue {}
extension Float: HTTPHeaderValue {}
extension Double: HTTPHeaderValue {}

