public struct URLPath {
  
  private var components: Array<URLPathComponent>
  
  public init(_ components: URLPathComponent...) {
    self.components = components
  }
  
  public init(_ string: String) {
    self.components
      = string
      .split(separator: "/")
      .map {
        guard
          !$0.urlPathComponent.contains("/"),
          let encoded = $0.urlPathComponent.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        else { fatalError("Cannot encode \"\($0.urlPathComponent)\" as url path component") }
        return encoded
    }
  }
  
  public mutating func append(_ component: URLPathComponent) {
    components.append(component)
  }
  
  public func appending(_ component: URLPathComponent) -> URLPath{
    var copy = self
    copy.components.append(component)
    return copy
  }
  
  public mutating func append(_ other: URLPath) {
    components.append(contentsOf: other.components)
  }
  
  public func appending(_ other: URLPath) -> URLPath{
    var copy = self
    copy.components.append(contentsOf: other.components)
    return copy
  }
  
  public var pathString: String { components.reduce(into: "", { $0.append("/\($1)") }) }
}

extension URLPath: CustomStringConvertible {
  public var description: String { pathString }
}

extension URLPath: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    self.init(stringLiteral)
  }
}

extension URLPath: ExpressibleByArrayLiteral {
  public init(arrayLiteral components: URLPathComponent...) {
    self.components = components
  }
}

public protocol URLPathComponent {
  var urlPathComponent: String { get }
}

extension URLPathComponent where Self: LosslessStringConvertible {
  public var urlPathComponent: String { description }
}
extension Bool: URLPathComponent {}
extension String: URLPathComponent {}
extension Substring: URLPathComponent {}
extension UInt: URLPathComponent {}
extension Int: URLPathComponent {}
extension Float: URLPathComponent {}
extension Double: URLPathComponent {}
