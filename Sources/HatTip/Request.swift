import Foundation

public struct Request {

    public enum ResponseBodyHint {
        case data
        case file(url: URL? = nil)
    }

    public var method: Method
    public var uri: URI
    public var headers: Headers
    public var body: MessageBody?

    public var responseBodyHint: ResponseBodyHint

    public init(
        method: Method = .GET,
        uri: URI,
        headers: Headers = [],
        body: MessageBody? = nil,
        responseBodyHint: ResponseBodyHint = .data
        ) {

        self.method = method
        self.uri = uri
        self.headers = headers
        self.body = body
        self.responseBodyHint = responseBodyHint
    }
}
