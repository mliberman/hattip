import Foundation

/// A structure representing the components of a uniform resource identifier (URI).
///
/// The components of the URI are combined to form the full URI string:
/// ```
/// scheme://[[user:[password]@]hostname[:port]]path[?query]
/// ```
///
public struct URI: Equatable, RawRepresentable, CustomStringConvertible, ExpressibleByStringLiteral {

    /// A URI scheme.
    public enum Scheme: String, Equatable {
        case http
        case https
    }

    /// A representation of the URI path as an array of its components.
    ///
    /// Besides the `Path.init(components:)`, a `Path` can be constructed a
    /// number of ways:
    ///
    /// ```
    /// // `Array<String>` literal
    /// let path: URI.Path = ["first", "second", "third"]
    /// print(path.components) // ["first", "second", "third"]
    ///
    /// // `String`
    /// let pathString = "/first/second/third"
    /// let path = URI.Path(pathString: pathString)
    /// print(path.components) // ["first", "second", "third"]
    ///
    /// // `String` literal
    /// let path: URI.Path = "first/second/third"
    /// print(path.components) // ["first", "second", "third"]
    /// ```
    ///
    /// When the `Path` builds a `String` value for use in constructing a URI:
    /// * It always begins with a `"/"`, and is never empty.
    /// * Its components are joined by a `"/"`.
    ///
    /// Examples:
    ///
    /// ```
    /// print(URI.Path()) // "/"
    /// print(URI.Path.empty) // "/"
    /// print(["first", "second"] as URI.Path) // "/first/second"
    /// ```
    ///
    /// - Note: Although a valid URI path must begin with a `"/"`, the
    /// `String`-based `Path` initializers do not enforce this restriction.
    /// - Important: The `Path` does not perform any percent encoding or decoding
    /// on its component strings.
    ///
    public struct Path: Equatable, RawRepresentable, CustomStringConvertible, ExpressibleByArrayLiteral, ExpressibleByStringLiteral {

        public var components: [String]

        /// Initializes a `Path` with a list of path components.
        ///
        /// - Parameter components: The initial components for this path.
        public init(components: [String] = []) {
            self.components = components
        }

        /// Initializes a `Path` by parsing a path string.
        ///
        /// - Parameter pathString: The path string to split for this path's components.
        public init(pathString: String) {
            self.components = pathString.split(separator: "/").map(String.init)
        }

        /// Returns the empty path.
        public static let empty: URI.Path = .init()

        /// Returns the path's string by joining its components with `"/"` and
        /// prepending a root `"/"`.
        public var pathString: String {
            return "/" + self.components.joined(separator: "/")
        }

        /// Appends the components of another path to the receiver.
        ///
        /// - Parameter other: The path whose components will be appended
        /// to the receiver's.
        public mutating func append(_ other: URI.Path) {
            self.components.append(contentsOf: other.components)
        }

        /// Appends the components of another path to the receiver.
        ///
        /// - Parameter other: The path whose components will be appended
        /// to the receiver's.
        /// - Returns: A copy of the receiver with the other path's components
        /// appended.
        public mutating func appending(_ other: URI.Path) -> URI.Path {
            var result = self
            result.append(other)
            return result
        }

        /// Appends a list of path components or path strings to the receiver.
        ///
        /// - Parameter elements: The components or path strings to append to the
        /// receiver's.
        /// - Note: Each element of `elements` is split on the `"/"` separator.
        public mutating func append(_ elements: [String]) {
            self.components.append(
                contentsOf: elements.flatMap {
                    return $0.split(separator: "/").map(String.init)
                }
            )
        }

        /// Appends a list of path components or path strings to the receiver.
        ///
        /// - Parameter elements: The components or path strings to append to the
        /// receiver's.
        /// - Note: Each element of `elements` is split on the `"/"` separator.
        public mutating func append(_ elements: String...) {
            self.append(elements)
        }

        /// Appends a list of path components or path strings to the receiver.
        ///
        /// - Parameter elements: The components or path strings to append to the
        /// receiver's.
        /// - Returns: A copy of the receiver with the path components or path
        /// strings appended.
        /// - Note: Each element of `elements` is split on the `"/"` separator.
        public mutating func appending(_ elements: [String]) -> URI.Path {
            var result = self
            result.append(elements)
            return result
        }

        /// Appends a list of path components or path strings to the receiver.
        ///
        /// - Parameter elements: The components or path strings to append to the
        /// receiver's.
        /// - Returns: A copy of the receiver with the path components or path
        /// strings appended.
        /// - Note: Each element of `elements` is split on the `"/"` separator.
        public mutating func appending(_ elements: String...) -> URI.Path {
            return self.appending(elements)
        }

        /// See `RawRepresentable`.
        public var rawValue: String {
            return self.pathString
        }

        /// See `RawRepresentable`.
        public init(rawValue: String) {
            self.init(pathString: rawValue)
        }

        /// See `CustomStringConvertible`.
        public var description: String {
            return self.pathString
        }

        /// See `ExpressibleByArrayLiteral`.
        public init(arrayLiteral elements: String...) {
            self.components = elements
        }

        /// See `ExpressibleByStringLiteral`.
        public init(stringLiteral value: String) {
            self.init(rawValue: value)
        }
    }

    /// A representation of the URI query as an array of name-value pairs.
    ///
    /// Besides the `Query.init(items:)` initializer, a `Query` can be constructed
    /// a number of ways:
    ///
    /// ```
    /// // `Array<(String, String)>` literal
    /// let query: URI.Query = [("name0", "value0"), ("name1", "value1")]
    /// print(query) // "name0=value0&name1=value1"
    ///
    /// // `String`
    /// let queryString = "name0=value0&name1=value1"
    /// let query = URI.Query(queryString: queryString)
    /// print(query.items[0]) // Item(name: "name0", value: "value0")
    ///
    /// // `String` literal
    /// let query: URI.Query = "name0=value0&name1=value1"
    /// print(query.items[1]) // Item(name: "name1", value: "value1")
    /// ```
    ///
    /// When the `Query` builds a `String` value for use in constructing a URI:
    /// * It does _not_ begin with the `"?"` character.
    /// * Its components are joined by the `Query.delimiter` character.
    ///
    /// Examples:
    ///
    /// ```
    /// print(URI.Query()) // ""
    /// print([("name0", "value0"), ("name1", "value1")] as URI.Query) // "name0=value0&name1=value1"
    /// ```
    ///
    /// - Important: Neither the `Query` nor the `Query.Item` perform any percent
    /// encoding or decoding on their component strings.
    ///
    public struct Query: Equatable, RawRepresentable, CustomStringConvertible, ExpressibleByArrayLiteral, ExpressibleByStringLiteral {

        /// The delimeter used between consecutive query items in the
        /// query string.
        public static let delimiter: Character = "&"

        /// A simple representation of a query name-value pair.
        public struct Item: Equatable, RawRepresentable, CustomStringConvertible {

            public var name: String
            public var value: String

            /// Initializes a query item.
            ///
            /// - Parameters:
            ///   - name: The name for this query item.
            ///   - value: The value for this query item.
            public init(name: String, value: String) {
                self.name = name
                self.value = value
            }

            /// Initializes a query item by parsing a string of the format `"name=value"`.
            ///
            /// - Parameter itemString: The string to parse.
            /// - Note: If `itemString` does not contain exactly one `"="` character,
            /// the initializer fails.
            public init?(itemString: String) {
                let nameAndValue = itemString.split(separator: "=")
                guard nameAndValue.count == 2 else { return nil }
                self.name = String(nameAndValue[0])
                self.value = String(nameAndValue[1])
            }

            /// Returns a string representation, of the format `"name=value"`, of the receiver
            /// for use in building a query string.
            public var itemString: String {
                return "\(self.name)=\(self.value)"
            }

            /// See `RawRepresentable`.
            public var rawValue: String {
                return self.itemString
            }

            /// See `RawRepresentable`.
            public init?(rawValue: String) {
                self.init(itemString: rawValue)
            }

            /// See `CustomStringConvertible`.
            public var description: String {
                return self.itemString
            }
        }

        public var items: [Item]

        /// Initializes a query with a list of query items.
        ///
        /// - Parameter items: The initial query items for this query.
        public init(items: [Item] = []) {
            self.items = items
        }

        /// Initializes a query by parsing a query string.
        ///
        /// - Parameter queryString: The query string to parse.
        public init(queryString: String) {
            self.items = queryString
                    .split(separator: Self.delimiter)
                    .compactMap { URI.Query.Item(itemString: String($0)) }
        }

        /// Returns a query string formed by joining the receiver's component
        /// item strings with the `Query.delimiter` character.
        ///
        /// See `Query.Item.itemString`.
        public var queryString: String {
            return self.items
                .map { $0.itemString }
                .joined(separator: String(Self.delimiter))
        }

        /// See `RawRepresentable`.
        public var rawValue: String {
            return self.queryString
        }

        /// See `RawRepresentable`.
        public init(rawValue: String) {
            self.init(queryString: rawValue)
        }

        /// See `CustomStringConvertible`.
        public var description: String {
            return self.queryString
        }

        /// See `ExpressibleByArrayLiteral`.
        public init(arrayLiteral elements: (String, String)...) {
            self.items = elements.map { URI.Query.Item(name: $0, value: $1) }
        }

        /// See `ExpressibleByStringLiteral`.
        public init(stringLiteral value: String) {
            self.init(queryString: value)
        }
    }

    public var scheme: Scheme
    public var user: String?
    public var password: String?
    public var host: String?
    public var port: Int?
    public var path: Path
    public var query: Query?

    /// Initializes a `URI`.
    ///
    /// - Parameters:
    ///   - scheme: The scheme for this URI.
    ///   - user: The optional username for this URI.
    ///   - password: The optional password for this URI.
    ///   - host: The optional host for this URI.
    ///   - port: The optional port for this URI.
    ///   - path: The path for this URI.
    ///   - query: The optional query for this URI.
    public init(
        scheme: Scheme = .https,
        user: String? = nil,
        password: String? = nil,
        host: String? = nil,
        port: Int? = nil,
        path: Path = .empty,
        query: Query? = nil
        ) {

        self.scheme = scheme
        self.user = user
        self.password = password
        self.host = host
        self.port = port
        self.path = path
        self.query = query
    }

    /// Initializes a URI by parsing a URI string.
    ///
    /// - Parameter uriString: The string to parse.
    /// - Note: The `URLComponents` structure is used to parse the input string. If the
    /// `URLComponents` initializer fails, this initializer also fails.
    public init?(uriString: String) {
        guard
            let components = URLComponents(string: uriString),
            let scheme = components.scheme.flatMap({ URI.Scheme(rawValue:$0) })
            else { return nil }
        self.scheme = scheme
        self.user = components.user
        self.password = components.password
        self.host = components.host
        self.port = components.port
        self.path = URI.Path(pathString: components.path)
        self.query = components.query.map(URI.Query.init(queryString:))
    }

    /// Returns a URI string formed by combining the receiver's components.
    ///
    /// The `URI`'s components are combined in the form:
    /// ```
    /// scheme://[[user:[password]@]host[:port]]path[?query]
    /// ```
    public var uriString: String {
        var result = "\(self.scheme.rawValue)://"
        if let host = self.host {
            if let user = self.user {
                result += "\(user):\(self.password ?? "")@"
            }
            result += host
            if let port = self.port {
                result += ":\(port)"
            }
        }
        result += self.path.pathString
        if let queryString = self.query?.queryString, !queryString.isEmpty {
            result += "?\(queryString)"
        }
        return result
    }

    /// Returns a `URL` constructed from the receiver's `uriString`.
    public var url: URL {
        return URL(string: self.uriString)!
    }

    /// See `RawRepresentable`.
    public var rawValue: String {
        return self.uriString
    }

    /// See `RawRepresentable`.
    public init?(rawValue: String) {
        self.init(uriString: rawValue)
    }

    /// See `CustomStringConvertible`.
    public var description: String {
        return self.uriString
    }

    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(uriString: value)!
    }
}
