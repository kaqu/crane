import Foundation.NSData
import Foundation.NSURL

public struct HTTPResponse {
  public var url: URL
  public var statusCode: HTTPStatusCode
  public var headers: HTTPHeaders
  public var body: Data

  public init(
    url: URL,
    statusCode: HTTPStatusCode,
    headers: HTTPHeaders,
    body: Data
  ) {
    self.url = url
    self.statusCode = statusCode
    self.headers = headers
    self.body = body
  }
}
