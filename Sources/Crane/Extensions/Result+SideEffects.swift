internal extension Result {

  @discardableResult
  func onSuccess(_ action: (Success) -> Void) -> Self {
    switch self {
    case let .success(value): action(value)
    case .failure: break
    }
    return self
  }

  @discardableResult
  func onFailure(_ action: (Failure) -> Void)  -> Self {
    switch self {
    case .success: break
    case let .failure(error): action(error)
    }
    return self
  }
}
