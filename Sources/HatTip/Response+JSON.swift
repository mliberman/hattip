import Foundation

enum ResponseError: Error {

    case noBody
    case fileError(Error)
    case decodingError(Error)
    case serverError(String)
}

protocol ServerResponseError: Error, Decodable, CustomStringConvertible { }

extension Response {

    func decodeError<E: ServerResponseError>(
        _ errorType: E.Type = E.self,
        using decoder: JSONDecoder
        ) -> Result<Response, ResponseError> {

        guard self.statusCode >= 400 else { return .success(self) }
        guard let body = self.body else { return .failure(.noBody) }
        do {
            let data = try body.read()
            do {
                let serverError = try decoder.decode(E.self, from: data)
                return .failure(.serverError(serverError.description))
            } catch {
                return .failure(.decodingError(error))
            }
        } catch {
            return .failure(.fileError(error))
        }
    }

    func decode<R: Decodable>(
        _ responseType: R.Type = R.self,
        using decoder: JSONDecoder
        ) -> Result<R, ResponseError> {

        guard let body = self.body else { return .failure(.noBody) }
        do {
            let data = try body.read()
            do {
                let response = try decoder.decode(R.self, from: data)
                return .success(response)
            } catch {
                return .failure(.decodingError(error))
            }
        } catch {
            return .failure(.fileError(error))
        }
    }

    func decode<R: Decodable, E: ServerResponseError>(
        _ responseType: R.Type = R.self,
        _ errorType: E.Type = E.self,
        using decoder: JSONDecoder
        ) -> Result<R, ResponseError> {

        return self
            .decodeError(E.self, using: decoder)
            .flatMap { $0.decode(R.self, E.self, using: decoder) }
    }
}
