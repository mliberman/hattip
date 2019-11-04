/// A structure that represents an HTTP response message.
public struct Response {

    public var statusCode: Int
    public var headers: Headers
    public var body: MessageBody?

    /// Initializes a response.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code for this response.
    ///   - headers: The HTTP header fields for this response.
    ///   - body: The HTTP message body for this response.
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

/// A generic analog to `Response` intended for decoded
/// HTTP message response bodies.
public struct DecodedResponse<Body> {

    public var statusCode: Int
    public var headers: Headers
    public var body: Body

    /// Initializes a response.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code for this response.
    ///   - headers: The HTTP header fields for this response.
    ///   - body: The decoded HTTP message body for this response.
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

    /// Replaces a raw HTTP response message body with its decoded contents.
    ///
    /// - Parameter body: The decoded body for this response.
    public func decoded<Body>(with body: Body) -> DecodedResponse<Body> {
        return .init(
            statusCode: self.statusCode,
            headers: self.headers,
            body: body
        )
    }
}

extension DecodedResponse {

    /// Transforms the `body` property of the receiver.
    ///
    /// - Parameter transform: The transformation to apply to the receiver's `body`.
    public func map<NewBody>(_ transform: (Body) -> NewBody) -> DecodedResponse<NewBody> {
        return .init(
            statusCode: self.statusCode,
            headers: self.headers,
            body: transform(self.body)
        )
    }
}
