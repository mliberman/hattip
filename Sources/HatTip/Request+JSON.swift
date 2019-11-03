import Foundation

enum RequestError: Error {
    case encodingError(Error)
}

extension Request {

    /// Encodes the given `json` using the given `encoder`, and sets the `"Content-Type"`
    /// header to `"application/json"`.
    mutating func encode<B: MessageBodyEncodable>(
        json: B,
        using encoder: JSONEncoder
        ) throws {

        self.body = try json.encode(using: encoder)
        self.headers.replaceOrAdd(.contentType(.json))
    }

    func encoding<B: MessageBodyEncodable>(
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

    mutating func encode<B: MessageBodyEncodable>(
        json: B,
        with options: JSONEncodingOptions = .default
        ) throws {

        try self.encode(json: json, using: .init(options: options))
    }

    func encoding<B: MessageBodyEncodable>(
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

    struct JSONEncodingOptions {

        var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys
        var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate

        static var `default`: JSONEncodingOptions { return .init() }
    }
}

extension JSONEncoder {

    convenience init(options: Request.JSONEncodingOptions) {
        self.init()
        self.keyEncodingStrategy = options.keyEncodingStrategy
        self.dateEncodingStrategy = options.dateEncodingStrategy
    }
}
