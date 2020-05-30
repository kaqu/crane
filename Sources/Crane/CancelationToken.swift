public final class CancelationToken {
  
  public let cancel: () -> Void
  
  public init(_ cancel: @escaping () -> Void) {
    self.cancel = cancel
  }
}
