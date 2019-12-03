import Foundation

/// A structure that represents an HTTP request message.
public struct Request: CustomStringConvertible {

    /// A hint to the client indicating how the response's body should be
    /// stored.
    /// - Note: Clients might not necessarily abide by this hint.
    public enum ResponseBodyHint {

        /// The response's body should be stored in memory as `Data`.
        case data

        /// The response's body should be stored on disk. The `url` can
        /// be optionally provided to determine the location of the file.
        case file(url: URL? = nil)
    }

    public var method: HTTPMethod
    public var uri: URI
    public var headers: Headers
    public var body: MessageBody?
    public var responseBodyHint: ResponseBodyHint

    /// Initializes a request.
    ///
    /// - Parameters:
    ///   - method: The HTTP method for this request.
    ///   - uri: The target URI for this request.
    ///   - headers: The HTTP header fields for this request.
    ///   - body: The optional HTTP message body for this request.
    ///   - responseBodyHint: The optional response body hint for the client
    ///   processing this request.
    public init(
        method: HTTPMethod = .GET,
        uri: URI,
        headers: Headers = [],
        body: MessageBody? = nil,
        responseBodyHint: ResponseBodyHint = .data
        ) {

        self.method = method
        self.uri = uri
        self.headers = headers
        self.body = body
        self.responseBodyHint = responseBodyHint
    }

    /// The textual representation of this HTTP request message.
    public var message: String {
        var lines = ["\(self.method) \(self.uri.originString) HTTP/1.1"]
        lines += self.headers.headers.map { "\($0.name): \($0.value)" }
        if case let .some(.data(data)) = self.body,
            let body = String(data: data, encoding: .utf8) {
                lines.append(body)
        }
        return lines.joined(separator: "\n")
    }

    /// See `CustomStringConvertible`.
    public var description: String {
        return self.message
    }
}
