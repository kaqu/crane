import XCTest
@testable import CraneURL


final class URLPathTests: XCTestCase {
  
  func test() {
    let path: URLPath = ["test/super", %("id", of: Int.self), "account"]
    let res = path.resolve(using: .some(path.parameters.updated {
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
