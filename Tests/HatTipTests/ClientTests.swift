import Foundation
@testable import HatTip
import XCTest

final class ClientTests: XCTestCase {

    var client: Client!

    override func setUp() {
        super.setUp()
        self.client = URLSession.shared
    }

    override func tearDown() {
        self.client = nil
        super.tearDown()
    }

    private func uri(
        path: URI.Path = .empty,
        query: URI.Query? = nil
        ) -> URI {

        return URI(
            host: "jsonplaceholder.typicode.com",
            path: path,
            query: query
        )
    }

    func testGet() {

        struct Post: Decodable, MessageBodyDecodable {
            var userId: Int
            var id: Int
            var title: String
            var body: String
        }

        let request = Request(method: .GET, uri: self.uri(path: "/posts"))
        let expectation = self.expectation(description: "Response")
        self.client.send(request) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.statusCode, 200)
                guard case .some(.data) = response.body else {
                    XCTFail("Expected `Data` body in response")
                    break
                }
                XCTAssertNoThrow(response.decode([Post].self))
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
