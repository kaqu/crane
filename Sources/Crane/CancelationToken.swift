public final class CancelationToken {
  
  private let cancel: () -> Void
  
  public init(_ cancel: @escaping () -> Void) {
    self.cancel = cancel
  }// TODO: to complete??
}
