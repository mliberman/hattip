import Foundation

extension URLRequest {

    var headers: HTTPHeaders {
        get {
            return self.allHTTPHeaderFields.map { namesAndValues in
                return HTTPHeaders(
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
