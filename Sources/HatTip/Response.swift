/// A structure that represents an HTTP response message.
public struct Response: CustomStringConvertible {

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

    /// The textual representation of this HTTP response message.
    public var message: String {
        var lines = ["HTTP/1.1 \(self.statusCode)"]
        lines += self.headers.headers.map { "\($0.name): \($0.value)" }
        if case let .some(.data(data)) = self.body,
            let body = String(data: data, encoding: .utf8) {
                lines.append(body)
        }
        return lines.joined(separator: "\n")
    }

    // See `CustomStringConvertible`
    public var description: String {
        return self.message
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
