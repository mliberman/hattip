import Foundation

public enum RequestError: Error {
    case encodingError(Error)
}

extension Request {

    /// Encodes the given `json` using the given `encoder`, and sets the `"Content-Type"`
    /// header to `"application/json"`.
    public mutating func encode<B: MessageBodyEncodable>(
        json: B,
        using encoder: JSONEncoder
        ) throws {

        let body = try json.encode(using: encoder)
        self.body = body
        self.headers.replaceOrAppend(.contentType(.json))
        if case let .data(data) = body {
            self.headers.replaceOrAppend(.contentLength(data.count))
        }
    }

    public func encoding<B: MessageBodyEncodable>(
        json: B,
        using encoder: JSONEncoder
        ) -> Result<Request, RequestError> {

        do {
            var result = self
            try result.encode(json: json, using: encoder)
            return .success(result)
        } catch {
            return .failure(.encodingError(error))
        }
    }

    public mutating func encode<B: MessageBodyEncodable>(
        json: B,
        with options: JSONEncodingOptions = .default
        ) throws {

        try self.encode(json: json, using: .init(options: options))
    }

    public func encoding<B: MessageBodyEncodable>(
        json: B,
        with options: JSONEncodingOptions = .default
        ) -> Result<Request, RequestError> {

        do {
            var result = self
            try result.encode(json: json, with: options)
            return .success(result)
        } catch {
            return .failure(.encodingError(error))
        }
    }
}

extension Request {

    public struct JSONEncodingOptions {

        public var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys
        public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate

        public static var `default`: JSONEncodingOptions { return .init() }
    }
}

extension JSONEncoder {

    public convenience init(options: Request.JSONEncodingOptions) {
        self.init()
        self.keyEncodingStrategy = options.keyEncodingStrategy
        self.dateEncodingStrategy = options.dateEncodingStrategy
    }
}
