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

        struct GetPost: GetAPIContract {

            typealias ResponseBody = Post

            var id: Int

            var uri: URI {
                return makeUri(path: ["posts", "\(self.id)"])
            }
        }

        let expectation = self.expectation(description: "completion")
        self.client.send(GetPost(id: 1)) { result in
            switch result {
            case let .success(response):
                switch response.body {
                case let .success(body):
                    XCTAssertEqual(body.id, 1)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)")
                }
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5)
    }

    func testPostAPIContract() {

        struct PostPost: PostAPIContract {

            struct RequestBody: Encodable, MessageBodyEncodable {
                var userId: Int
                var title: String
                var body: String
            }

            typealias ResponseBody = Post

            var uri: URI { return makeUri(path: "posts") }

            var requestBody: RequestBody
        }

        let expectation = self.expectation(description: "completion")
        let requestBody = PostPost.RequestBody(userId: 1, title: "Test", body: "Test body.")
        self.client.send(PostPost(requestBody: requestBody)) { result in
            switch result {
            case let .success(response):
                switch response.body {
                case let .success(body):
                    XCTAssertEqual(body.userId, requestBody.userId)
                    XCTAssertEqual(body.title, requestBody.title)
                    XCTAssertEqual(body.body, requestBody.body)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)")
                }
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5)
    }

    func testPutAPIContract() {

        struct PutPost: PutAPIContract {

            typealias RequestBody = Post
            typealias ResponseBody = Post

            var requestBody: RequestBody

            var uri: URI { return makeUri(path: ["posts", "\(self.requestBody.id)"]) }
        }

        let expectation = self.expectation(description: "completion")
        let requestBody = Post(userId: 10, id: 1, title: "Title", body: "Body")
        self.client.send(PutPost(requestBody: requestBody)) { result in
            switch result {
            case let .success(response):
                switch response.body {
                case let .success(body):
                    XCTAssertEqual(body, requestBody)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)")
                }
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5)
    }
}
