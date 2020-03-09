internal protocol AnyOptional {
  var string: String { get }
  static var wrappedType: Any.Type { get }
}

extension Optional: AnyOptional {
  var string: String {
    switch self {
    case let .some(wrapped): return String(describing: wrapped)
    case .none: return ""
    }
  }
  internal static var wrappedType: Any.Type { Wrapped.self }
}

internal func anyOptionalString(from any: Any) -> String {
  guard let optional = any as? AnyOptional
  else { return String(describing: any) }
  return optional.string
}
