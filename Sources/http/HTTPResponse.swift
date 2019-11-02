import Foundation

struct HTTPResponse: HTTPMessage {
    var statusCode: Int
    var headers: HTTPHeaders = []
    var body: HTTPMessageBody?
}

extension HTTPResponse {

    init(body: HTTPMessageBody?, response: URLResponse?, error: Error?) throws {
        if let error = error { throw error }
        guard let response = response as? HTTPURLResponse else {
            throw HTTPError(reason: "No `HTTPURLResponse` received")
        }
        self.statusCode = response.statusCode
        self.headers = response.headers
        self.body = body
    }

    init(data: Data?, response: URLResponse?, error: Error?) throws {
        try self.init(
            body: data.map(HTTPMessageBody.data),
            response: response,
            error: error
        )
    }

    init(file: URL?, response: URLResponse?, error: Error?) throws {
        try self.init(
            body: file.map(HTTPMessageBody.file),
            response: response,
            error: error
        )
    }
}
