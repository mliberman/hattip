import Foundation

struct Request: Message {

    enum ResponseBodyHint {
        case data
        case file(url: URL? = nil)
    }

    var method: Method = .GET
    var uri: URI
    var headers: Headers = []
    var body: MessageBody?

    var responseBodyHint: ResponseBodyHint = .data
}
