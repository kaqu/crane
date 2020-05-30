public protocol NetworkCallRequest: NetworkRequest {
  associatedtype Call: NetworkCall where Call.Request == Self
}
