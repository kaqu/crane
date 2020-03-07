import XCTest
@testable import CraneURL


final class URLQueryTests: XCTestCase {
  
  func test() {
    let query: URLQuery = ["id": %("id", of: Int.self), "test": "value enc"]
    let res = query.resolve(using: Parameters {
      %(42, for: "id")
      %("aaa", for: "name")
    })
    guard case .success("id=42&test=value%20enc&") = res else {
      return XCTFail("\(res)")
    }
  }
}
