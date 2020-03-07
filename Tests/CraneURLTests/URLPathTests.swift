import XCTest
@testable import CraneURL


final class URLPathTests: XCTestCase {
  
  func test() {
    let path: URLPath = ["test/super", %("id", of: Int.self), "account"]
    let res = path.resolve(using: Parameters {
      %(42, for: "id")
      %("aaa", for: "name")
    })
    guard case .success("/test/super/42/account") = res else {
      return XCTFail("\(res)")
    }
  }
}
