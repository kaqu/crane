internal protocol AnyOptional {
  static var wrappedType: Any.Type { get }
}

extension Optional: AnyOptional {
  internal static var wrappedType: Any.Type { Wrapped.self }
}
