import Foundation

public enum ResponseError: Error {
    case noBody
    case decodingError(Error)
    case serverMessage(String)
}

public protocol ErrorMessageBodyDecodable: Error, MessageBodyDecodable, CustomStringConvertible { }

extension Response {

    internal func decodeError<E: ErrorMessageBodyDecodable>(
        _ errorType: E.Type = E.self,
        using decoder: JSONDecoder
        ) -> DecodedResponse<Result<Response, ResponseError>> {

        guard self.statusCode >= 400 else {
            return self.decoded(with: .success(self))
        }
        guard let body = self.body else {
            return self.decoded(with: .failure(.noBody))
        }
        do {
            let serverError = try E.decode(from: body, using: decoder)
            return self.decoded(with: .failure(.serverMessage(serverError.description)))
        } catch {
            return self.decoded(with: .failure(.decodingError(error)))
        }
    }

    internal func decodeError<E: ErrorMessageBodyDecodable>(
        _ errorType: E.Type = E.self,
        with options: Response.JSONDecodingOptions = .default
        ) -> DecodedResponse<Result<Response, ResponseError>> {

        return self.decodeError(errorType, using: .init(options: options))
    }

    internal func decode<R: MessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        using decoder: JSONDecoder
        ) -> Result<R, ResponseError> {

        guard let body = self.body else { return .failure(.noBody) }
        do {
            return try .success(R.decode(from: body, using: decoder))
        } catch {
            return .failure(.decodingError(error))
        }
    }

    public func decode<R: MessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        using decoder: JSONDecoder
        ) -> DecodedResponse<Result<R, ResponseError>> {

        return self.decoded(with: self.decode(R.self, using: decoder))
    }

    public func decode<R: MessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        with options: Response.JSONDecodingOptions = .default
        ) -> DecodedResponse<Result<R, ResponseError>> {

        return self.decode(responseType, using: .init(options: options))
    }

    public func decode<R: MessageBodyDecodable, E: ErrorMessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        _ errorType: E.Type = E.self,
        using decoder: JSONDecoder
        ) -> DecodedResponse<Result<R, ResponseError>> {

        return self
            .decodeError(E.self, using: decoder)
            .map { $0.flatMap { $0.decode(R.self, using: decoder) } }
    }

    public func decode<R: MessageBodyDecodable, E: ErrorMessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        _ errorType: E.Type = E.self,
        with options: Response.JSONDecodingOptions = .default
        ) -> DecodedResponse<Result<R, ResponseError>> {

        return self.decode(responseType, errorType, using: .init(options: options))
    }
}

extension Response {

    public struct JSONDecodingOptions {

        public var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
        public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate

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
