import Foundation

public struct Request: Message {

    public enum ResponseBodyHint {
        case data
        case file(url: URL? = nil)
    }

    public var method: Method = .GET
    public var uri: URI
    public var headers: Headers = []
    public var body: MessageBody?

    public var responseBodyHint: ResponseBodyHint = .data
}
