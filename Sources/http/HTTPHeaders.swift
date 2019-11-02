struct HTTPHeaders {

    var headers: [HTTPHeader] = []

    mutating func add(_ header: HTTPHeader) {
        self.headers.append(header)
    }

    mutating func add(name: String, value: String) {
        self.add(.init(name: name, value: value))
    }

    func adding(_ header: HTTPHeader) -> HTTPHeaders {
        var result = self
        result.add(header)
        return result
    }

    func adding(name: String, value: String) -> HTTPHeaders {
        return self.adding(.init(name: name, value: value))
    }

    mutating func remove(name: String) {
        self.headers.removeAll(where: { $0.name == name })
    }

    func removing(name: String) -> HTTPHeaders {
        var result = self
        result.remove(name: name)
        return result
    }

    mutating func replaceOrAdd(_ header: HTTPHeader) {
        self.remove(name: header.name)
        self.add(header)
    }

    /// Returns the value of the first `HTTPHeader` found with the given `name`.
    func value(for name: String) -> String? {
        return self.headers.first(where: { $0.name == name })?.value
    }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {

    init(arrayLiteral elements: HTTPHeader...) {
        self.init(headers: elements)
    }
}

struct HTTPHeader {
    var name: String
    var value: String
}

protocol HTTPHeaderType {
    static var name: String { get }
    var value: String { get }
}

extension HTTPHeaderType {
    var name: String { return Self.name }
    var header: HTTPHeader { return .init(name: self.name, value: self.value) }
}

protocol BasicHTTPHeaderType: HTTPHeaderType, RawRepresentable where RawValue == String { }

extension BasicHTTPHeaderType {
    var value: String { return self.rawValue }
}

extension HTTPHeader {

    enum ContentType: String, BasicHTTPHeaderType {
        static var name: String { return "Content-Type" }
        case json = "application/json"
    }

    static func contentType(_ value: ContentType) -> HTTPHeader {
        return value.header
    }

    enum Authorization: HTTPHeaderType {

        static var name: String { return "Authorization" }

        case basic(username: String, password: String)
        case bearer(token: String)

        var value: String {
            switch self {
            case let .basic(username, password):
                let token = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
                return "Basic \(token)"
            case let .bearer(token):
                return "Bearer \(token)"
            }
        }
    }

    static func authorization(_ value: Authorization) -> HTTPHeader {
        return value.header
    }
}
