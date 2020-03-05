public enum Either<Left, Right> {
  case left(Left)
  case right(Right)
}

public extension Either {
  func mapLeft<T>(_ transform: (Left) -> T) -> Either<T, Right> {
    switch self {
    case let .left(value):
      return .left(transform(value))
    case let .right(value):
      return .right(value)
    }
  }
  
  func mapRight<T>(_ transform: (Right) -> T) -> Either<Left, T> {
    switch self {
    case let .left(value):
      return .left(value)
    case let .right(value):
      return .right(transform(value))
    }
  }
}

extension Either: ExpressibleByStringLiteral where Left: StringProtocol {
  
}

extension Either: ExpressibleByStringLiteral where Right: StringProtocol {
  
}

extension Either: ExpressibleByStringLiteral where Left: AnyParameter {
  
}

extension Either: ExpressibleByStringLiteral where Right: AnyParameter {
  
}
