import Foundation

extension Response {

    init(body: MessageBody?, response: URLResponse?, error: Error?) throws {
        if let error = error { throw error }
        guard let response = response as? HTTPURLResponse else {
            throw HatTipError(reason: "No `HTTPURLResponse` received")
        }
        self.statusCode = response.statusCode
        self.headers = response.headers
        self.body = body
    }

    init(data: Data?, response: URLResponse?, error: Error?) throws {
        try self.init(
            body: data.map(MessageBody.data),
            response: response,
            error: error
        )
    }

    init(file: URL?, response: URLResponse?, error: Error?) throws {
        try self.init(
            body: file.map(MessageBody.file),
            response: response,
            error: error
        )
    }
}

extension HTTPURLResponse {

    var headers: Headers {
        return Headers(
            headers: self.allHeaderFields
                .compactMap { (anyName, anyValue) in
                    guard
                        let name = anyName as? String,
                        let value = anyValue as? String
                        else { return nil }
                    return Header(name: name, value: value)
                }
        )
    }
}
