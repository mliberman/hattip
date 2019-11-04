import Foundation
import HatTip
import XCTest

final class URITests: XCTestCase {

    func testUrl() {
        XCTAssertEqual(
            URI(scheme: .https, host: "www.example.com").url.absoluteString,
            "https://www.example.com/"
        )
        XCTAssertEqual(
            URI(scheme: .https, host: "www.example.com", path: "/test").url.absoluteString,
            "https://www.example.com/test"
        )
        XCTAssertEqual(
            URI(scheme: .https, host: "www.example.com", path: "test").url.absoluteString,
            "https://www.example.com/test"
        )
        XCTAssertEqual(
            URI(scheme: .https, host: "www.example.com", path: "/test/long/path").url.absoluteString,
            "https://www.example.com/test/long/path"
        )
        XCTAssertEqual(
            URI(scheme: .https, host: "www.example.com", path: "test/long/path").url.absoluteString,
            "https://www.example.com/test/long/path"
        )
        XCTAssertEqual(
            URI(
                scheme: .https,
                user: "user",
                password: "password",
                host: "www.example.com",
                port: 80,
                path: "/test/long/path",
                query: [
                    ("parameter1", "1"),
                    ("parameter2", "2")
                ]
            ).url.absoluteString,
            "https://user:password@www.example.com:80/test/long/path?parameter1=1&parameter2=2"
        )
    }

    func assertEqual(_ uri: URI, _ urlString: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(uri.url.absoluteString, urlString, file: file, line: line)
        XCTAssertEqual(uri, URI(rawValue: urlString)!, file: file, line: line)
    }
}
