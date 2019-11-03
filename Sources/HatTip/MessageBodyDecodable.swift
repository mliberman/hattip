import Foundation

public protocol MessageBodyDecodable {
    static func decode(from body: MessageBody?, using decoder: JSONDecoder) throws -> Self
}

extension MessageBodyDecodable where Self: Decodable {

    public static func decode(from body: MessageBody?, using decoder: JSONDecoder) throws -> Self {
        guard let body = body else {
            let reason = "Expected response body for `\(String(describing: type(of: self)))`"
            throw HatTipError(reason: reason)
        }
        return try decoder.decode(Self.self, from: body.read())
    }
}

extension Response {

    public struct NoBody: MessageBodyDecodable {

        public init() { }

        public static func decode(
            from body: MessageBody?,
            using decoder: JSONDecoder
            ) throws -> Response.NoBody {

            if let body = body {
                let typeName = String(describing: type(of: self))
                switch body {
                case let .data(data):
                    if let dataString = String(data: data, encoding: .utf8) {
                        let reason = "Unexpected response body for `\(typeName)`: \(dataString)"
                        throw HatTipError(reason: reason)
                    } else {
                        throw HatTipError(reason: "Unexpected response body for `\(typeName)`")
                    }
                case let .file(url):
                    let reason = "Unexpected response body for `\(typeName)` at \(url.path)"
                    throw HatTipError(reason: reason)
                }
            }
            return .init()
        }
    }

    public struct IgnoreBody: ErrorMessageBodyDecodable {

        public var body: MessageBody

        public init(body: MessageBody) {
            self.body = body
        }

        public static func decode(
            from body: MessageBody?,
            using decoder: JSONDecoder
            ) throws -> Response.IgnoreBody {

            guard let body = body else {
                let reason = "Expected response body for `\(String(describing: type(of: self)))`"
                throw HatTipError(reason: reason)
            }
            return .init(body: body)
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

    public struct FileDownload: MessageBodyDecodable {

        public var url: URL

        public init(url: URL) {
            self.url = url
        }

        public static func decode(
            from body: MessageBody?,
            using decoder: JSONDecoder
            ) throws -> Response.FileDownload {

            let typeName = String(describing: type(of: self))
            guard let body = body else {
                let reason = "Expected response body for `\(typeName)`"
                throw HatTipError(reason: reason)
            }
            guard case let .file(url) = body else {
                let reason = "Expected file download for `\(typeName)`"
                throw HatTipError(reason: reason)
            }
            return .init(url: url)
        }
    }
}

extension Array: MessageBodyDecodable where Element: Decodable { }

extension Dictionary: MessageBodyDecodable where Key: Decodable, Value: Decodable { }
