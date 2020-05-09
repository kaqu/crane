import XCTest
@testable import CraneURL


final class URLPathTests: XCTestCase {
  
  func test() {
    let id: Int = 0
    let name: String = "Blob"
    
    XCTAssertEqual(("static/path" as URLPath).description, "/static/path")
    XCTAssertEqual((["dynamic/path", id, name] as URLPath).description, "/dynamic/path/0/Blob")
    XCTAssertEqual(URLPath("string/path/\(id)/\(name)").description, "/string/path/0/Blob")
  }
}
