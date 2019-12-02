import Foundation

extension Request {

    /// Encodes a request body as JSON data into the receiver's `body`.
    ///
    /// - Parameters:
    ///   - json: The `MessageBodyEncodable` request body to encode.
    ///   - encoder: The `JSONEncoder` to use to encode `json`.
    /// - Returns: A `Result` structure holding either a copy of the
    /// receiver with the encoded `body`, or the error thrown during
    /// encoding.
    public func encoding<B: MessageBodyEncodable>(
        json: B,
        using encoder: JSONEncoder
        ) -> Result<Request, BasicError> {

        return json
            .encode(using: encoder)
            .map { body in
                var result = self
                result.body = body
                result.headers.replaceOrAppend(.contentType(.json))
                return result
            }
    }

    /// Encodes a request body as JSON data into the receiver's `body`.
    ///
    /// - Parameters:
    ///   - json: The `MessageBodyEncodable` request body to encode.
    ///   - options: Options used to create a `JSONEncoder` for the encoding.
    /// - Returns: A `Result` structure holding either a copy of the
    /// receiver with the encoded `body`, or the error thrown during
    /// encoding.
    public func encoding<B: MessageBodyEncodable>(
        json: B,
        with options: JSONEncodingOptions = .default
        ) -> Result<Request, BasicError> {

        return self.encoding(json: json, using: .init(options: options))
    }
}

extension Request {

    /// A structure containing configurable properties of a `JSONEncoder`.
    public struct JSONEncodingOptions {

        public var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy
        public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy

        public init(
            keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys,
            dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate
            ) {

            self.keyEncodingStrategy = keyEncodingStrategy
            self.dateEncodingStrategy = dateEncodingStrategy
        }

        public static var `default`: JSONEncodingOptions { return .init() }
    }
}

extension JSONEncoder {

    /// Initializes a `JSONEncoder` and applies the properties contained in `options`.
    ///
    /// - Parameter options: The propertiess to assign to the `JSONEncoder`.
    public convenience init(options: Request.JSONEncodingOptions) {
        self.init()
        self.keyEncodingStrategy = options.keyEncodingStrategy
        self.dateEncodingStrategy = options.dateEncodingStrategy
    }
}
