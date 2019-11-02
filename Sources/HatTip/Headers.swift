struct Headers {

    var headers: [Header] = []

    mutating func add(_ header: Header) {
        self.headers.append(header)
    }

    mutating func add(name: String, value: String) {
        self.add(.init(name: name, value: value))
    }

    func adding(_ header: Header) -> Headers {
        var result = self
        result.add(header)
        return result
    }

    func adding(name: String, value: String) -> Headers {
        return self.adding(.init(name: name, value: value))
    }

    mutating func remove(name: String) {
        self.headers.removeAll(where: { $0.name == name })
    }

    func removing(name: String) -> Headers {
        var result = self
        result.remove(name: name)
        return result
    }

    mutating func replaceOrAdd(_ header: Header) {
        self.remove(name: header.name)
        self.add(header)
    }

    /// Returns the value of the first `Header` found with the given `name`.
    func value(for name: String) -> String? {
        return self.headers.first(where: { $0.name == name })?.value
    }
}

extension Headers: ExpressibleByArrayLiteral {

    init(arrayLiteral elements: Header...) {
        self.init(headers: elements)
    }
}

struct Header {
    var name: String
    var value: String
}

protocol HeaderType {
    static var name: String { get }
    var value: String { get }
}

extension HeaderType {
    var name: String { return Self.name }
    var header: Header { return .init(name: self.name, value: self.value) }
}

protocol BasicHeaderType: HeaderType, RawRepresentable where RawValue == String { }

extension BasicHeaderType {
    var value: String { return self.rawValue }
}

extension Header {

    enum ContentType: String, BasicHeaderType {
        static var name: String { return "Content-Type" }
        case json = "application/json"
    }

    static func contentType(_ value: ContentType) -> Header {
        return value.header
    }

    enum Authorization: HeaderType {

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

    static func authorization(_ value: Authorization) -> Header {
        return value.header
    }
}
