import Foundation

/// A protocol that enables types to be decoded from JSON
/// HTTP message response bodies.
public protocol MessageBodyDecodable {

    /// Decodes an instance of the type from an HTTP message body
    /// using the provided decoder.
    ///
    /// - Parameters:
    ///   - body: The HTTP response message body to decode.
    ///   - decoder: The decoder to use.
    /// - Returns: A decoded instance of the type, or an error thrown
    /// during decoding.
    static func decode(from body: MessageBody?, using decoder: JSONDecoder) -> Result<Self, BasicError>
}

/// Automatic `MessageBodyEncodable` conformance for `Encodable` types.
extension MessageBodyDecodable where Self: Decodable {

    public static func decode(
        from body: MessageBody?,
        using decoder: JSONDecoder
        ) -> Result<Self, BasicError> {

        guard let body = body else {
            let typeName = String(describing: type(of: self))
            let reason = "Expected response body to decode `\(typeName)`"
            return .failure(.init(reason: reason))
        }
        do {
            return try .success(decoder.decode(Self.self, from: body.read()))
        } catch let error as DecodingError {
            return .failure(.init(decodingError: error))
        } catch let error as NSError {
            return .failure(.init(unknownError: error))
        }
    }
}

extension Response {

    /// An empty structure that "decodes" from an empty response body.
    ///
    /// - Note: `NoBody.decode(from:using:)` will return a `.failure`
    /// if it encounters a non-empty response body. Use `IgnoreBody` to
    /// explicitly ignore non-empty response bodies.
    public struct NoBody: MessageBodyDecodable {

        public init() { }

        public static func decode(
            from body: MessageBody?,
            using decoder: JSONDecoder
            ) -> Result<Response.NoBody, BasicError> {

            if let body = body {
                let typeName = String(describing: type(of: self))
                switch body {
                case let .data(data):
                    if let dataString = String(data: data, encoding: .utf8) {
                        let reason = "Unexpected response body for `\(typeName)`: \(dataString)"
                        return .failure(.init(reason: reason))
                    } else {
                        let reason = "Unexpected response body for `\(typeName)`"
                        return .failure(.init(reason: reason))
                    }
                case let .file(url):
                    let reason = "Unexpected response body for `\(typeName)` at \(url.path)"
                    return .failure(.init(reason: reason))
                }
            }
            return .success(.init())
        }
    }

    /// An structure that "decodes" from a non-empty response body
    /// by simply storing the raw body.
    ///
    /// - Note: `IgnoreBody.decode(from:using:)` will return a `.failure`
    /// if it encounters an empty response body. Use `NoBody` to handle
    /// empty response bodies.
    public struct IgnoreBody: ErrorMessageBodyDecodable {

        public var body: MessageBody

        public init(body: MessageBody) {
            self.body = body
        }

        public static func decode(
            from body: MessageBody?,
            using decoder: JSONDecoder
            ) -> Result<Response.IgnoreBody, BasicError> {

            guard let body = body else {
                let typeName = String(describing: type(of: self))
                let reason = "Expected response body to decode `\(typeName)`"
                return .failure(.init(reason: reason))
            }
            return .success(.init(body: body))
        }

        public var description: String {
            switch self.body {
            case let .data(data):
                return String(data: data, encoding: .utf8)!
            case let .file(url):
                return url.absoluteString
            }
        }
    }

    /// A structure containing a URL that "decodes" itself from a
    /// `MessageBody.file` for file downloads.
    public struct FileDownload: MessageBodyDecodable {

        public var url: URL

        public init(url: URL) {
            self.url = url
        }

        public static func decode(
            from body: MessageBody?,
            using decoder: JSONDecoder
            ) -> Result<Response.FileDownload, BasicError> {

            let typeName = String(describing: type(of: self))
            guard let body = body else {
                let reason = "Expected response body for `\(typeName)`"
                return .failure(.init(reason: reason))
            }
            guard case let .file(url) = body else {
                let reason = "Expected file download for `\(typeName)`"
                return .failure(.init(reason: reason))
            }
            return .success(.init(url: url))
        }
    }
}

extension Array: MessageBodyDecodable where Element: Decodable { }

extension Dictionary: MessageBodyDecodable where Key: Decodable, Value: Decodable { }
