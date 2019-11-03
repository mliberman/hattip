import Foundation

protocol APIContract {

    static var method: Method { get }

    static var encoder: JSONEncoder { get }
    associatedtype RequestBodyType: MessageBodyEncodable

    static var decoder: JSONDecoder { get }
    associatedtype ResponseBodyType: MessageBodyDecodable
    associatedtype ErrorResponseBodyType: ErrorMessageBodyDecodable

    typealias ResultType = Result<ResponseBodyType, MessageError>

    var uri: URI { get }
    var headers: Headers { get }
    var requestBody: RequestBodyType { get }
    var responseBodyHint: Request.ResponseBodyHint { get }
}

enum MessageError: Error {
    case requestError(RequestError)
    case clientError(Error)
    case responseError(ResponseError)
}

extension APIContract {

    static var encoder: JSONEncoder {
        return .init(options: .init(dateEncodingStrategy: .iso8601))
    }

    var headers: Headers { return [] }

    var responseBodyHint: Request.ResponseBodyHint { return .data }

    func makeRequest() -> Result<Request, RequestError> {
        return Request
            .init(
                method: Self.method,
                uri: self.uri,
                headers: self.headers,
                responseBodyHint: self.responseBodyHint
            )
            .encoding(json: self.requestBody, using: Self.encoder)
    }
}

extension APIContract where RequestBodyType == Request.NoBody {

    var requestBody: RequestBodyType {
        return Request.NoBody()
    }
}

extension APIContract {

    static var decoder: JSONDecoder {
        return .init(options: .init(dateDecodingStrategy: .iso8601))
    }

    func decode(response: Response) -> Result<ResponseBodyType, ResponseError> {
        return response.decode(
            ResponseBodyType.self,
            ErrorResponseBodyType.self,
            using: Self.decoder
        )
    }
}

protocol GetAPIContract: APIContract where RequestBodyType == Request.NoBody { }

extension GetAPIContract {
    static var method: Method { return .GET }
}

protocol DownloadAPIContract: GetAPIContract {
    var downloadUrl: URL? { get }
}

extension DownloadAPIContract {
    var downloadUrl: URL? { return nil }
    var responseBodyHint: Request.ResponseBodyHint { return .file(url: self.downloadUrl) }
}

protocol PostAPIContract: APIContract { }

extension PostAPIContract {
    static var method: Method { return .POST }
}

protocol PatchAPIContract: APIContract { }

extension PatchAPIContract {
    static var method: Method { return .PATCH }
}

protocol DeleteAPIContract: APIContract { }

extension DeleteAPIContract {
    static var method: Method { return .DELETE }
}
