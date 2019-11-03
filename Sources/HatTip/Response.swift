public struct Response {

    public var statusCode: Int
    public var headers: Headers
    public var body: MessageBody?

    public init(
        statusCode: Int,
        headers: Headers = [],
        body: MessageBody? = nil
        ) {

        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }
}

public struct DecodedResponse<Body> {

    public var statusCode: Int
    public var headers: Headers
    public var body: Body

    public init(
        statusCode: Int,
        headers: Headers,
        body: Body
        ) {

        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }
}

extension Response {

    public func decoded<Body>(with body: Body) -> DecodedResponse<Body> {
        return .init(
            statusCode: self.statusCode,
            headers: self.headers,
            body: body
        )
    }
}

extension DecodedResponse {

    public func map<NewBody>(_ transform: (Body) -> NewBody) -> DecodedResponse<NewBody> {
        return .init(
            statusCode: self.statusCode,
            headers: self.headers,
            body: transform(self.body)
        )
    }
}
