import XCTest
@testable import Crane


final class CraneTests: XCTestCase {
  
  func test() {
    let session = URLNetworkSession(host: "httpbin.org")
    session.make(TestCall.Request(userID: 100)) { (result) in
      print(result)
    }.cancel()
    sleep(3)
  }
}


enum TestCall: NetworkCall {
  struct Request: NetworkCallRequest {
    typealias Call = TestCall
    typealias Body = Void
    
    var urlPath: URLPath
    var urlQuery: URLQuery = ["some": "default"]

    init(userID: Int)  {
      self.urlPath = URLPath("/anything/\(userID)")
    }
  }

  enum Response: NetworkResponse {
    case string(String)
    case customError(Int)
    
    static func from<Context>(_ response: HTTPResponse, in context: Context) -> Result<TestCall.Response, NetworkError> where Context : NetworkSession {
      guard case .ok = response.statusCode
      else { return .success(.customError(response.statusCode.rawValue)) }
      return .success(.string("\(response.statusCode.rawValue): " + (String(data: response.body, encoding: .utf8) ?? "N/A")))
    }
  }
}
