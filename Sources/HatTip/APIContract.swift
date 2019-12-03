import Foundation

public protocol APIContract {

    static var encoder: JSONEncoder { get }
    associatedtype RequestBody: MessageBodyEncodable = Request.NoBody

    static var decoder: JSONDecoder { get }
    associatedtype ResponseBody: MessageBodyDecodable = Response.NoBody
    associatedtype ErrorResponseBody: ErrorMessageBodyDecodable = Response.IgnoreBody

    typealias DecodedResponse = HatTip.DecodedResponse<Swift.Result<ResponseBody, BasicError>>
    typealias Result = Swift.Result<HatTip.DecodedResponse<ResponseBody>, BasicError>

    var method: HTTPMethod { get }
    var uri: URI { get }
    var headers: Headers { get }
    var requestBody: RequestBody { get }
    var responseBodyHint: Request.ResponseBodyHint { get }

    func prepareRequest(_ request: inout Request) throws

    func didReceiveResponse(_ response: Response, for request: Request)
}

extension APIContract {

    public func prepareRequest(_ request: inout Request) throws { }

    public func didReceiveResponse(_ response: Response, for request: Request) { }

    internal typealias IntermediateResult = Swift.Result<DecodedResponse, BasicError>

    internal static func flatten(_ result: Self.IntermediateResult) -> Self.Result {
        return result.flatMap { response in
            switch response.body {
            case let .success(body):
                return .success(response.map { _ in body })
            case let .failure(error):
                return .failure(error)
            }
        }
    }
}

extension APIContract {

    public static var encoder: JSONEncoder {
        return .init(options: .init(dateEncodingStrategy: .iso8601))
    }

    public var headers: Headers { return [] }

    public var responseBodyHint: Request.ResponseBodyHint { return .data }

    public func makeRequest() -> Swift.Result<Request, BasicError> {
        let result = Request
            .init(
                method: self.method,
                uri: self.uri,
                headers: self.headers,
                responseBodyHint: self.responseBodyHint
            )
            .encoding(json: self.requestBody, using: Self.encoder)
        guard case var .success(request) = result else { return result }
        do {
            try self.prepareRequest(&request)
            return .success(request)
        } catch let basicError as BasicError {
            return .failure(basicError)
        } catch {
            return .failure(.init(unknownError: error as NSError))
        }
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

public protocol DownloadAPIContract: GetAPIContract {
    var downloadUrl: URL? { get }
}

extension DownloadAPIContract {
    public var method: HTTPMethod { return .GET }
    public var downloadUrl: URL? { return nil }
    public var responseBodyHint: Request.ResponseBodyHint { return .file(url: self.downloadUrl) }
}
