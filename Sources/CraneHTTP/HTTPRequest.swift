import Foundation

/// Struct represention of http request.
/// It is used as intermediate representation for requests allowing to
/// provide custom network stack usage (unrelated to Foundation).
/// See RFC2616, RFC7230 and RFC7540 for details.
/// Version of http is intentionally omitted as session implementation detail.
public struct HTTPRequest {

  public var method: HTTPMethod
  public var url: URL
  public var headers: HTTPHeaders
  public var body: Data

  public init(
    method: HTTPMethod = .get,
    url: URL,
    headers: HTTPHeaders = [:],
    body: Data = .init()
  ) {
    self.method = method
    self.url = url
    self.headers = headers
    self.body = body
  }
}
