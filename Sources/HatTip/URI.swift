import Foundation

// MARK: - URI

public struct URI: Equatable {

    public enum Scheme: String, Equatable {
        case http
        case https
    }

    public struct Path: Equatable {
        public var components: [String] = []
    }

    public struct Query: Equatable {

        public static let delimiter: Character = "&"

        public struct Item: Equatable {
            public var name: String
            public var value: String
        }

        public var items: [Item] = []
    }

    public var scheme: Scheme = .https
    public var user: String?
    public var password: String?
    public var host: String
    public var port: Int?
    public var path: Path = .empty
    public var query: Query?
}

extension URI: RawRepresentable {

    public var rawValue: String {
        return self.urlString
    }

    public init?(rawValue: String) {
        guard
            let components = URLComponents(string: rawValue),
            let scheme = components.scheme.flatMap({ URI.Scheme(rawValue:$0) }),
            let host = components.host
            else { return nil }
        self.scheme = scheme
        self.user = components.user
        self.password = components.password
        self.host = host
        self.port = components.port
        self.path = URI.Path(rawValue: components.path)
        if let queryString = components.query {
            guard let query = URI.Query(rawValue: queryString) else { return nil }
            self.query = query
        }
    }
}

extension URI {

    public var url: URL {
        var components = URLComponents()
        components.scheme = self.scheme.rawValue
        components.user = self.user
        components.password = self.password
        components.host = self.host
        components.port = self.port
        components.path = self.path.rawValue
        components.percentEncodedQuery = self.query?.rawValue
        return components.url!
    }

    public var urlString: String {
        return self.url.absoluteString
    }
}

extension URI: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}

// MARK: - Path Extensions

extension URI.Path {

    public static var empty: URI.Path { return .init() }

    public mutating func append(_ other: URI.Path) {
        self.components.append(contentsOf: other.components)
    }

    public mutating func appending(_ other: URI.Path) -> URI.Path {
        var result = self
        result.append(other)
        return result
    }

    public mutating func append(_ elements: [String]) {
        self.components.append(
            contentsOf: elements.flatMap { $0.split(separator: "/").map(String.init) }
        )
    }

    public mutating func append(_ elements: String...) {
        self.append(elements)
    }

    public mutating func appending(_ elements: [String]) -> URI.Path {
        var result = self
        result.append(elements)
        return result
    }

    public mutating func appending(_ elements: String...) -> URI.Path {
        return self.appending(elements)
    }
}

extension URI.Path: RawRepresentable {

    public var rawValue: String {
        return "/" + self.components.joined(separator: "/")
    }

    public init(rawValue: String) {
        self.components = rawValue.split(separator: "/").map(String.init)
    }
}

extension URI.Path: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: String...) {
        self.components = elements
    }
}

extension URI.Path: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

// MARK: - Query Extensions

extension URI.Query.Item: RawRepresentable {

    public var rawValue: String {
        return "\(self.name)=\(self.value)"
    }

    public init?(rawValue: Self.RawValue) {
        let nameAndValue = rawValue.split(separator: "=")
        guard nameAndValue.count == 2 else { return nil }
        self.name = String(nameAndValue[0])
        self.value = String(nameAndValue[1])
    }
}

extension URI.Query: RawRepresentable {

    public var rawValue: String {
        return self.items
            .map { $0.rawValue }
            .joined(separator: String(Self.delimiter))
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }


    public init?(rawValue: Self.RawValue) {
        guard let decoded = rawValue.removingPercentEncoding else { return nil }
        self.items = decoded
                .split(separator: Self.delimiter)
                .compactMap { URI.Query.Item(rawValue: String($0)) }
    }
}

extension URI.Query: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: (String, String)...) {
        self.items = elements.map { URI.Query.Item(name: $0, value: $1) }
    }
}

extension URI.Query: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}
