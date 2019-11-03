import Foundation

public protocol APIContract {

    static var method: Method { get }

    static var encoder: JSONEncoder { get }
    associatedtype RequestBody: MessageBodyEncodable = Request.NoBody

    static var decoder: JSONDecoder { get }
    associatedtype ResponseBody: MessageBodyDecodable = Response.NoBody
    associatedtype ErrorResponseBody: ErrorMessageBodyDecodable = Response.IgnoreBody

    typealias DecodedResponse = HatTip.DecodedResponse<Swift.Result<ResponseBody, ResponseError>>
    typealias Result = Swift.Result<DecodedResponse, MessageSendError>

    var uri: URI { get }
    var headers: Headers { get }
    var requestBody: RequestBody { get }
    var responseBodyHint: Request.ResponseBodyHint { get }
}

public enum MessageSendError: Error {
    case requestError(RequestError)
    case clientError(Error)
}

public enum APIContractError: Error {
    case requestError(RequestError)
    case clientError(Error)
    case responseError(DecodedResponse<ResponseError>)
}

extension APIContract {

    public static var encoder: JSONEncoder {
        return .init(options: .init(dateEncodingStrategy: .iso8601))
    }

    public var headers: Headers { return [] }

    public var responseBodyHint: Request.ResponseBodyHint { return .data }

    public func makeRequest() -> Swift.Result<Request, RequestError> {
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

    public var requestBody: RequestBody {
        return Request.NoBody()
    }
}

extension APIContract {

    public static var decoder: JSONDecoder {
        return .init(options: .init(dateDecodingStrategy: .iso8601))
    }

    public func decode(response: Response) -> DecodedResponse {
        return response.decode(
            ResponseBody.self,
            ErrorResponseBody.self,
            using: Self.decoder
        )
    }
}

public protocol GetAPIContract: APIContract where RequestBody == Request.NoBody { }

extension GetAPIContract {
    public static var method: Method { return .GET }
}

public protocol DownloadAPIContract: GetAPIContract {
    var downloadUrl: URL? { get }
}

extension DownloadAPIContract {
    public var downloadUrl: URL? { return nil }
    public var responseBodyHint: Request.ResponseBodyHint { return .file(url: self.downloadUrl) }
}

public protocol PostAPIContract: APIContract { }

extension PostAPIContract {
    public static var method: Method { return .POST }
}

public protocol PutAPIContract: APIContract { }

extension PutAPIContract {
    public static var method: Method { return .PUT }
}

public protocol PatchAPIContract: APIContract { }

extension PatchAPIContract {
    public static var method: Method { return .PATCH }
}

public protocol DeleteAPIContract: APIContract { }

extension DeleteAPIContract {
    public static var method: Method { return .DELETE }
}
