public struct Headers {

    public var headers: [Header]

    public init(headers: [Header] = []) {
        self.headers = headers
    }

    public mutating func add(_ header: Header) {
        self.headers.append(header)
    }

    public mutating func add(name: String, value: String) {
        self.add(.init(name: name, value: value))
    }

    public func adding(_ header: Header) -> Headers {
        var result = self
        result.add(header)
        return result
    }

    public func adding(name: String, value: String) -> Headers {
        return self.adding(.init(name: name, value: value))
    }

    public mutating func remove(name: String) {
        self.headers.removeAll(where: { $0.name == name })
    }

    public func removing(name: String) -> Headers {
        var result = self
        result.remove(name: name)
        return result
    }

    public mutating func replaceOrAdd(_ header: Header) {
        self.remove(name: header.name)
        self.add(header)
    }

    /// Returns the value of the first `Header` found with the given `name`.
    public func value(for name: String) -> String? {
        return self.headers.first(where: { $0.name == name })?.value
    }
}

extension Headers: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: Header...) {
        self.init(headers: elements)
    }
}

public struct Header {

    public var name: String
    public var value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

public protocol HeaderType {
    static var name: String { get }
    var value: String { get }
}

extension HeaderType {
    public var name: String { return Self.name }
    public var header: Header { return .init(name: self.name, value: self.value) }
}

public protocol BasicHeaderType: HeaderType, RawRepresentable where RawValue == String { }

extension BasicHeaderType {
    public var value: String { return self.rawValue }
}

extension Header {

    public enum ContentType: String, BasicHeaderType {
        public static var name: String { return "Content-Type" }
        case json = "application/json"
    }

    public static func contentType(_ value: ContentType) -> Header {
        return value.header
    }

    public enum Authorization: HeaderType {

        public static var name: String { return "Authorization" }

        case basic(username: String, password: String)
        case bearer(token: String)

        public var value: String {
            switch self {
            case let .basic(username, password):
                let token = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
                return "Basic \(token)"
            case let .bearer(token):
                return "Bearer \(token)"
            }
        }
    }

    public static func authorization(_ value: Authorization) -> Header {
        return value.header
    }
}
