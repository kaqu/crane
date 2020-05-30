import Foundation.NSData
import Foundation.NSURL

public struct HTTPRequest {
  public var url: URL
  public var method: HTTPMethod
  public var headers: HTTPHeaders
  public var body: Data

  public init(
    _ method: HTTPMethod = .get,
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
