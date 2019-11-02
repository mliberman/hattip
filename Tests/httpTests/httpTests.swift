import XCTest
@testable import http

final class httpTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(http().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
