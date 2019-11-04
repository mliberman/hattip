import Foundation

extension Request {

    /// Returns a `URLRequest` structure populated by the receiver's properties.
    public var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: self.uri.url)
        urlRequest.httpMethod = self.method.rawValue
        urlRequest.headers = self.headers
        if case let .data(data) = self.body {
            urlRequest.httpBody = data
        }
        return urlRequest
    }
}

extension URLRequest {

    /// Converts between a `Headers` structure and the `URLRequest`'s
    /// `allHTTPHeaderFields` dictionary property.
    public var headers: Headers {
        get {
            return self.allHTTPHeaderFields.map { namesAndValues in
                return Headers(
                    headers: namesAndValues.map { (name, value) in
                        return .init(name: name, value: value)
                    }
                )
            } ?? .init()
        }
        set {
            self.allHTTPHeaderFields = newValue.headers.isEmpty
                ? nil
                : [String: String](
                    newValue.headers.map { ($0.name, $0.value) },
                    uniquingKeysWith: { (_, b) in b}
                )
        }
    }
}
