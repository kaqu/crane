import XCTest
@testable import CraneParameters


final class ParametersTests: XCTestCase {
  
  func test_empty_isValid() {
    let parameters: Parameters = .init()
    
    XCTAssert(parameters.isValid, "Empty parameters should be valid")
  }
}
