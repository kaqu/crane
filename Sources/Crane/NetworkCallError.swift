public protocol NetworkCallError: Error {
  init(from networkError: NetworkError)
}

extension NetworkError: NetworkCallError {
  public init(from networkError: NetworkError) {
    self = networkError
  }
}
