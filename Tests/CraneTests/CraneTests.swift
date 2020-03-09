import XCTest
@testable import Crane


final class CraneTests: XCTestCase {
  
  func test() {
    let session: URLNetworkSession = .init(host: "httpbin.org")
    session.make(TestCall.self, .init(userID: 10)) { (result) in
      print(result)
    }
    sleep(3)
  }
}


enum TestCall: NetworkCall {
  struct Request: NetworkRequest {
    typealias Body = Void
    var parameters: Parameters
    
    init(userID: Int) {
      parameters = [%(userID, for: "userID")]
    }
    
    static var path: URLPath = ["/anything", %("userID", of: Int.self)]
    static var query: URLQuery = ["some": %("some", of: String.self, default: "None")]
  }

  enum Response: NetworkResponse {
    case string(String)
    static func from(_ response: HTTPResponse) -> Result<TestCall.Response, NetworkError> {
      .success(.string("\(response.statusCode.rawValue): " + (String(data: response.body, encoding: .utf8) ?? "N/A")))
    }
  }
}
