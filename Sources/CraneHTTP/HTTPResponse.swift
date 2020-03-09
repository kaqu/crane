import Foundation.NSData
import Foundation.NSURL

/// Struct represention of http response.
/// It is used as intermediate representation for responses allowing to
/// provide custom network stack usage (unrelated to Foundation).
/// See RFC2616, RFC7230 and RFC7540 for details.
/// Version of http is intentionally omitted as implementation detail.
public struct HTTPResponse {
  
  public var url: URL
  public var statusCode: HTTPStatusCode
  public var headers: Dictionary<String, String>
  public var body: Data

  public init(
    url: URL,
    statusCode: HTTPStatusCode,
    headers: Dictionary<String, String>,
    body: Data
  ) {
    self.url = url
    self.statusCode = statusCode
    self.headers = headers
    self.body = body
  }
}
