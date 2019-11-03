import Foundation
@testable import HatTip
import XCTest

private func makeUri(
    path: URI.Path = .empty,
    query: URI.Query? = nil
    ) -> URI {

    return .init(
        host: "jsonplaceholder.typicode.com",
        path: path,
        query: query
    )
}

final class APIContractTests: XCTestCase {

    private var client: Client!

    override func setUp() {
        super.setUp()
        self.client = URLSession.shared
    }

    override func tearDown() {
        self.client = nil
        super.tearDown()
    }

    func testGetAPIContract() {

        struct GetPost: GetAPIContract {

            struct ResponseBodyType: Decodable, MessageBodyDecodable {
                var userId: Int
                var id: Int
                var title: String
                var body: String
            }

            typealias ErrorResponseBodyType = Response.IgnoreBody

            var id: Int

            var uri: URI {
                return makeUri(path: ["posts", "\(self.id)"])
            }
        }

        let expectation = self.expectation(description: "completion")
        self.client.send(GetPost(id: 1)) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.id, 1)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10)
    }
}
