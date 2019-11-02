import Foundation

struct Request: Message {
    var method: Method = .GET
    var uri: URI
    var headers: Headers = []
    var body: MessageBody?
}

extension Request {

    var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: self.uri.url)
        urlRequest.httpMethod = self.method.rawValue
        urlRequest.headers = self.headers
        if case let .data(body) = self.body {
            urlRequest.httpBody = body
        }
        return urlRequest
    }
}
