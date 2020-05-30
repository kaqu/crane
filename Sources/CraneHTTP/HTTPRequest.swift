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

//#warning("TODO: to decide which one")
//
//import Foundation.NSURLRequest
//
//public typealias HTTPRequest = URLRequest
//
//public extension URLRequest {
//  init(
//    _ method: HTTPMethod = .get,
//    url: URL,
//    headers: HTTPHeaders = [:],
//    body: Data = .init()
//  ) {
//    self.init(url: url)
//    self.httpMethod = method.rawValue
//    self.allHTTPHeaderFields = headers.dictionary
//    self.httpBody = body
//  }
//
//  var headers: HTTPHeaders { HTTPHeaders(allHTTPHeaderFields ?? [:]) }
//  var method: HTTPMethod { HTTPMethod(rawValue: httpMethod ?? "") ?? .get }
//}
