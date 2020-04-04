internal protocol AnyOptional {
  static var wrappedType: Any.Type { get }
  var stringValue: String? { get }
}

extension Optional: AnyOptional {
  internal static var wrappedType: Any.Type { Wrapped.self }
  internal var stringValue: String? {
    switch self {
    case let .some(wrapped):
      return String(describing: wrapped)
    case .none:
      return nil
    }
  }
}

internal func nonOptionalStringValue(of any: Any) -> String? {
  guard let optional = any as? AnyOptional
  else { return String(describing: any) }
  return optional.stringValue
}
