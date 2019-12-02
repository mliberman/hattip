import Foundation
import HatTip
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

private struct Post: Codable, Equatable, MessageBodyEncodable, MessageBodyDecodable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
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

        struct GetPost: APIContract {

            typealias ResponseBody = Post

            var method: HatTip.Method { return .GET }

            var id: Int

            var uri: URI {
                return makeUri(path: ["posts", "\(self.id)"])
            }
        }

        let expectation = self.expectation(description: "completion")
        self.client.send(GetPost(id: 1)) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.body.id, 1)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5)
    }

    func testPostAPIContract() {

        struct PostPost: APIContract {

            struct RequestBody: Encodable, MessageBodyEncodable {
                var userId: Int
                var title: String
                var body: String
            }

            typealias ResponseBody = Post

            var method: HatTip.Method { return .POST }

            var uri: URI { return makeUri(path: "posts") }

            var requestBody: RequestBody
        }

        let expectation = self.expectation(description: "completion")
        let requestBody = PostPost.RequestBody(userId: 1, title: "Test", body: "Test body.")
        self.client.send(PostPost(requestBody: requestBody)) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.body.userId, requestBody.userId)
                XCTAssertEqual(response.body.title, requestBody.title)
                XCTAssertEqual(response.body.body, requestBody.body)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5)
    }

    func testPutAPIContract() {

        struct PutPost: APIContract {

            typealias RequestBody = Post
            typealias ResponseBody = Post

            var method: HatTip.Method { return .PUT }

            var requestBody: RequestBody

            var uri: URI { return makeUri(path: ["posts", "\(self.requestBody.id)"]) }
        }

        let expectation = self.expectation(description: "completion")
        let requestBody = Post(userId: 10, id: 1, title: "Title", body: "Body")
        self.client.send(PutPost(requestBody: requestBody)) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.body, requestBody)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5)
    }
}
