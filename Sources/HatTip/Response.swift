public struct Response: Message {
    public var statusCode: Int
    public var headers: Headers = []
    public var body: MessageBody?
}

public struct DecodedResponse<Body> {
    public var statusCode: Int
    public var headers: Headers
    public var body: Body
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
