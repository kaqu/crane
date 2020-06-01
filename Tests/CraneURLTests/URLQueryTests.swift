import XCTest
@testable import CraneURL


final class URLQueryTests: XCTestCase {
  
  func test() {
    var query: URLQuery = ["id": 12, "name": "Blob", "remove": "nil"]
    XCTAssert(query["id"] == 12)
    XCTAssert(query["name"] == "Blob")
    query["pi"] = 3.14
    XCTAssert(query["pi"] == 3.14)
    query["remove"] = nil as String?
    XCTAssert(query["remove"] as String? == nil)
  }
}
