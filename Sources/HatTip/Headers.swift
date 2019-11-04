/// `Headers` represents a set of HTTP header fields as an array of `Header`
/// structures, each composed of a field name and field value.
///
/// - Note: All header field name comparisons are performed in a case-insensitive
/// manner.
public struct Headers {

    public var headers: [Header]

    /// Constructs a `Headers` structure.
    ///
    /// - Parameter headers: An initial array of `Header`s.
    public init(headers: [Header] = []) {
        self.headers = headers
    }

    /// Appends a header to the receiver's array.
    ///
    /// - Parameter header: The header to append.
    public mutating func append(_ header: Header) {
        self.headers.append(header)
    }

    /// Appends a header to the receiver's array.
    ///
    /// - Parameters:
    ///   - name: The name for the header field to append.
    ///   - value: The value for the header field to append.
    public mutating func append(name: String, value: String) {
        self.append(.init(name: name, value: value))
    }

    /// Appends a header field to the receiver's array.
    ///
    /// - Parameter header: The header field to append.
    /// - Returns: A copy of the receiver with the given header field appended.
    public func appending(_ header: Header) -> Headers {
        var result = self
        result.append(header)
        return result
    }

    /// Appends a header field to the receiver's array.
    ///
    /// - Parameters:
    ///   - name: The name for the header field to append.
    ///   - value: The value for the header field to append.
    /// - Returns: A copy of the receiver with the given header field appended.
    public func appending(name: String, value: String) -> Headers {
        return self.appending(.init(name: name, value: value))
    }

    /// Removes all header fields in the receiver's array with the given name (case-insensitive).
    ///
    /// - Parameter name: The name of the header fields to remove.
    public mutating func removeAll(withName name: String) {
        self.headers.removeAll(where: { $0.name.lowercased() == name.lowercased() })
    }

    /// Removes all header fields in the receiver's array with the given name (case-insensitive).
    ///
    /// - Parameter name: The name of the header fields to remove.
    /// - Returns: A copy of the receiver with all the header fields with the given name removed.
    public func removingAll(withName name: String) -> Headers {
        var result = self
        result.removeAll(withName: name)
        return result
    }

    /// Removes all header fields in the receiver's array with same name (case-insensitive) as
    /// the given header field, then appends the given header field.
    ///
    /// - Parameter header: The header field to replace or append.
    public mutating func replaceOrAppend(_ header: Header) {
        self.removeAll(withName: header.name)
        self.append(header)
    }

    /// Returns all the header fields with the given name (case-insensitive).
    ///
    /// - Parameter name: The name of the header fields to return.
    /// - Returns: An array of headers with a matching name (case-insensitive).
    public func headers(withName name: String) -> [Header] {
        return self.headers.filter { $0.name.lowercased() == name.lowercased() }
    }
}

extension Headers: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: Header...) {
        self.init(headers: elements)
    }
}

/// A simple representation of a header field as a name and value.
public struct Header {

    public var name: String
    public var value: String

    /// Constructs a `Header`.
    ///
    /// - Parameters:
    ///   - name: The header field name.
    ///   - value: The header field value.
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

/// A protocol for defining header field specifications.
public protocol HeaderType {
    static var name: String { get }
    var value: String { get }
}

extension HeaderType {
    public var name: String { return Self.name }
    public var header: Header { return .init(name: self.name, value: self.value) }
}

/// A protocol for defining basic string-valued header field specifications.
public protocol BasicHeaderType: HeaderType, RawRepresentable where RawValue == String { }

extension BasicHeaderType {
    public var value: String { return self.rawValue }
}

extension Header {

    /// The `"Content-Type"` header field.
    public enum ContentType: String, BasicHeaderType {
        public static var name: String { return "Content-Type" }
        case json = "application/json"
    }

    /// Creates a `"Content-Type"` header field.
    ///
    /// - Parameter type: The type to use as the header field value.
    /// - Returns: The `"Content-Type"` header field.
    public static func contentType(_ type: ContentType) -> Header {
        return type.header
    }

    /// The `"Authorization"` header field.
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

    /// Creates an `"Authorization"` header field.
    ///
    /// - Parameter authorization: The authorization to use as the header field value.
    public static func authorization(_ authorization: Authorization) -> Header {
        return authorization.header
    }
}
