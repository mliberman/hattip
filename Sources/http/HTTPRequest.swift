import Foundation

struct HTTPRequest: HTTPMessage {
    var method: HTTPMethod = .GET
    var uri: URI
    var headers: HTTPHeaders = []
    var body: HTTPMessageBody?
}

extension HTTPRequest {

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
