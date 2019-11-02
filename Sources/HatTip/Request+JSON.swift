import Foundation

extension Request {

    /// Encodes the given `json` using the given `encoder`, and sets the `"Content-Type"`
    /// header to `"application/json"`.
    mutating func encode<B: Encodable>(
        json: B,
        using encoder: JSONEncoder
        ) throws {

        self.body = .data(try encoder.encode(json))
        self.headers.replaceOrAdd(.contentType(.json))
    }

    func encoding<B: Encodable>(
        json: B,
        using encoder: JSONEncoder
        ) throws -> Request {

        var result = self
        try result.encode(json: json, using: encoder)
        return result
    }

    mutating func encode<B: Encodable>(
        json: B,
        with options: JSONEncodingOptions = .default
        ) throws {

        try self.encode(json: json, using: .init(options: options))
    }

    func encoding<B: Encodable>(
        json: B,
        with options: JSONEncodingOptions = .default
        ) throws -> Request {

        var result = self
        try result.encode(json: json, with: options)
        return result
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
