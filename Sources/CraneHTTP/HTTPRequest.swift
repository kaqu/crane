import Foundation.NSData
import Foundation.NSURL

/// Struct represention of http request.
/// It is used as intermediate representation for requests allowing to
/// provide custom network stack usage (unrelated to Foundation).
/// See RFC2616, RFC7230 and RFC7540 for details.
/// Version of http is intentionally omitted as session implementation detail.
public struct HTTPRequest {

  public var method: String
  public var url: URL
  public var headers: Dictionary<String, String>
  public var body: Data

  public init(
    method: String = "GET",
    url: URL,
    headers: Dictionary<String, String> = [:],
    body: Data = .init()
  ) {
    self.method = method
    self.url = url
    self.headers = headers
    self.body = body
  }
}
