import XCTest
@testable import CraneURL


final class URLQueryTests: XCTestCase {
  
  func test() {
    let query: URLQuery = [ %("id", of: Int.self)]
    let res = query.resolve(using: .some(query.parameters.updated {
      %(42, for: "id")
      %("aaa", for: "name")
    }))
    print(res)
//    print(path.resolve(using: path.parameters.updated {
//      %(42, for: "id")
//      %("aaa", for: "name")
//    })) // "/test/super/42/account"
  }
}
