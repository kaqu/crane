import XCTest
@testable import CraneURL


final class URLTests: XCTestCase {
  
  func test() {
    let url = URL(
      host: "example.org",
      path: "static/path/with space",
      query: ["some": "value"]
    )
    XCTAssertEqual(url?.description, "https://example.org/static/path/with%2520space?some=value")
  }
}
