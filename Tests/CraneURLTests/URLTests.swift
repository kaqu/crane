import XCTest
@testable import CraneURL


final class URLTests: XCTestCase {
  
  func test() {
    let res = URL.using(
      host: "example.org",
      path: ["test", %("id", of: Int.self, default: 1), "path"],
      query: ["some": "value", "name": %("name", of: String?.self)],
      with: Parameters(%("test", for: "name"))
    )
    print(res)
  }
}
