import Foundation

/// A protocol for decodable response bodies that represent errors from the request target.
public protocol ErrorMessageBodyDecodable: Error, MessageBodyDecodable, CustomStringConvertible { }

extension Response {

    internal func decodeError<E: ErrorMessageBodyDecodable>(
        _ errorType: E.Type = E.self,
        using decoder: JSONDecoder
        ) -> Result<Response, BasicError> {

        guard self.statusCode >= 400 else { return .success(self) }
        guard let body = self.body else {
            let typeName = String(describing: errorType)
            let reason = "Expected response body to decode `\(typeName)`"
            return .failure(.init(reason: reason))
        }
        switch E.decode(from: body, using: decoder) {
        case let .success(error):
            return .failure(
                .init(
                    reason: "[\(String(describing: type(of: error)))] \(error.description)",
                    underlyingError: error
                )
            )
        case let .failure(error):
            return .failure(error)
        }
    }

    internal func decodeError<E: ErrorMessageBodyDecodable>(
        _ errorType: E.Type = E.self,
        using decoder: JSONDecoder
        ) -> DecodedResponse<Result<Response, BasicError>> {

        return self.decoded(with: self.decodeError(errorType, using: decoder))
    }

    internal func decode<R: MessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        using decoder: JSONDecoder
        ) -> Result<R, BasicError> {

        guard let body = self.body else {
            let typeName = String(describing: responseType)
            let reason = "Expected response body to decode `\(typeName)`"
            return .failure(.init(reason: reason))
        }
        return R.decode(from: body, using: decoder)
    }

    public func decode<R: MessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        using decoder: JSONDecoder
        ) -> DecodedResponse<Result<R, BasicError>> {

        return self.decoded(with: self.decode(R.self, using: decoder))
    }

    public func decode<R: MessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        with options: Response.JSONDecodingOptions = .default
        ) -> DecodedResponse<Result<R, BasicError>> {

        return self.decode(responseType, using: .init(options: options))
    }

    public func decode<R: MessageBodyDecodable, E: ErrorMessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        _ errorType: E.Type = E.self,
        using decoder: JSONDecoder
        ) -> DecodedResponse<Result<R, BasicError>> {

        return self
            .decodeError(E.self, using: decoder)
            .map { $0.flatMap { $0.decode(R.self, using: decoder) } }
    }

    public func decode<R: MessageBodyDecodable, E: ErrorMessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        _ errorType: E.Type = E.self,
        with options: Response.JSONDecodingOptions = .default
        ) -> DecodedResponse<Result<R, BasicError>> {

        return self.decode(responseType, errorType, using: .init(options: options))
    }
}

extension Response {

    public struct JSONDecodingOptions {

        public var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
        public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy

        public init(
            keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
            dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
            ) {

            self.keyDecodingStrategy = keyDecodingStrategy
            self.dateDecodingStrategy = dateDecodingStrategy
        }

        public static var `default`: JSONDecodingOptions { return .init() }
    }
}

extension JSONDecoder {

    public convenience init(options: Response.JSONDecodingOptions) {
        self.init()
        self.keyDecodingStrategy = options.keyDecodingStrategy
        self.dateDecodingStrategy = options.dateDecodingStrategy
    }
}
