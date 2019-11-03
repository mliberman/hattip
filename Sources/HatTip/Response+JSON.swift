import Foundation

enum ResponseError: Error {
    case noBody
    case decodingError(Error)
    case serverMessage(String)
}

protocol ErrorMessageBodyDecodable: Error, MessageBodyDecodable, CustomStringConvertible { }

extension Response {

    func decodeError<E: ErrorMessageBodyDecodable>(
        _ errorType: E.Type = E.self,
        using decoder: JSONDecoder
        ) -> Result<Response, ResponseError> {

        guard self.statusCode >= 400 else { return .success(self) }
        guard let body = self.body else { return .failure(.noBody) }
        do {
            let serverError = try E.decode(from: body, using: decoder)
            return .failure(.serverMessage(serverError.description))
        } catch {
            return .failure(.decodingError(error))
        }
    }

    func decodeError<E: ErrorMessageBodyDecodable>(
        _ errorType: E.Type = E.self,
        with options: Response.JSONDecodingOptions = .default
        ) -> Result<Response, ResponseError> {

        return self.decodeError(errorType, using: .init(options: options))
    }

    func decode<R: MessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        using decoder: JSONDecoder
        ) -> Result<R, ResponseError> {

        guard let body = self.body else { return .failure(.noBody) }
        do {
            let response = try R.decode(from: body, using: decoder)
            return .success(response)
        } catch {
            return .failure(.decodingError(error))
        }
    }

    func decode<R: MessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        with options: Response.JSONDecodingOptions = .default
        ) -> Result<R, ResponseError> {

        return self.decode(responseType, using: .init(options: options))
    }

    func decode<R: MessageBodyDecodable, E: ErrorMessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        _ errorType: E.Type = E.self,
        using decoder: JSONDecoder
        ) -> Result<R, ResponseError> {

        return self
            .decodeError(E.self, using: decoder)
            .flatMap { $0.decode(R.self, E.self, using: decoder) }
    }

    func decode<R: MessageBodyDecodable, E: ErrorMessageBodyDecodable>(
        _ responseType: R.Type = R.self,
        _ errorType: E.Type = E.self,
        with options: Response.JSONDecodingOptions = .default
        ) -> Result<R, ResponseError> {

        return self.decode(responseType, errorType, using: .init(options: options))
    }
}

extension Response {

    struct JSONDecodingOptions {

        var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
        var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate

        static var `default`: JSONDecodingOptions { return .init() }
    }
}

extension JSONDecoder {

    convenience init(options: Response.JSONDecodingOptions) {
        self.init()
        self.keyDecodingStrategy = options.keyDecodingStrategy
        self.dateDecodingStrategy = options.dateDecodingStrategy
    }
}
