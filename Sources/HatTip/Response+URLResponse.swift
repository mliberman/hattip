import Foundation

extension Response {

    public static func make(
        body: MessageBody?,
        response: URLResponse?,
        error: NSError?,
        file: String = #file,
        line: UInt = #line
        ) -> Result<Response, BasicError> {

        if let error = error {
            return .failure(
                .init(
                    urlError: error,
                    file: file,
                    line: line
                )
            )
        }
        guard let response = response as? HTTPURLResponse else {
            return .failure(
                BasicError(
                    reason: "No `HTTPURLResponse`",
                    file: file,
                    line: line
                )
            )
        }
        return .success(
            .init(
                statusCode: response.statusCode,
                headers: response.headers,
                body: body
            )
        )
    }

    public static func make(
        data: Data?,
        response: URLResponse?,
        error: NSError?,
        file: String = #file,
        line: UInt = #line
        ) -> Result<Response, BasicError> {

        return self.make(
            body: data.map(MessageBody.data),
            response: response,
            error: error,
            file: file,
            line: line
        )
    }

    public static func make(
        url: URL?,
        response: URLResponse?,
        error: NSError?,
        file: String = #file,
        line: UInt = #line
        ) -> Result<Response, BasicError> {

        return self.make(
            body: url.map(MessageBody.file),
            response: response,
            error: error,
            file: file,
            line: line
        )
    }
}

extension HTTPURLResponse {

    public var headers: Headers {
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
