import Foundation

protocol APIContract {

    static var method: Method { get }

    static var encoder: JSONEncoder { get }
    associatedtype RequestBody: MessageBodyEncodable = Request.NoBody

    static var decoder: JSONDecoder { get }
    associatedtype ResponseBody: MessageBodyDecodable = Response.NoBody
    associatedtype ErrorResponseBody: ErrorMessageBodyDecodable = Response.IgnoreBody

    typealias Result = Swift.Result<ResponseBody, MessageError>

    var uri: URI { get }
    var headers: Headers { get }
    var requestBody: RequestBody { get }
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

    func makeRequest() -> Swift.Result<Request, RequestError> {
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

extension APIContract where RequestBody == Request.NoBody {

    var requestBody: RequestBody {
        return Request.NoBody()
    }
}

extension APIContract {

    static var decoder: JSONDecoder {
        return .init(options: .init(dateDecodingStrategy: .iso8601))
    }

    func decode(response: Response) -> Swift.Result<ResponseBody, ResponseError> {
        return response.decode(
            ResponseBody.self,
            ErrorResponseBody.self,
            using: Self.decoder
        )
    }
}

protocol GetAPIContract: APIContract where RequestBody == Request.NoBody { }

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

protocol PutAPIContract: APIContract { }

extension PutAPIContract {
    static var method: Method { return .PUT }
}

protocol PatchAPIContract: APIContract { }

extension PatchAPIContract {
    static var method: Method { return .PATCH }
}

protocol DeleteAPIContract: APIContract { }

extension DeleteAPIContract {
    static var method: Method { return .DELETE }
}
