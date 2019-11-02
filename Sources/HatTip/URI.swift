import Foundation

// MARK: - URI

struct URI: Equatable {

    enum Scheme: String, Equatable {
        case http
        case https
    }

    struct Path: Equatable {
        var components: [String] = []
    }

    struct Query: Equatable {

        static let delimiter: Character = "&"

        struct Item: Equatable {
            var name: String
            var value: String
        }

        var items: [Item] = []
    }

    var scheme: Scheme = .https
    var user: String?
    var password: String?
    var host: String
    var port: Int?
    var path: Path = .empty
    var query: Query?
}

extension URI: RawRepresentable {

    var rawValue: String {
        return self.urlString
    }

    init?(rawValue: String) {
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

    var url: URL {
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

    var urlString: String {
        return self.url.absoluteString
    }
}

extension URI: ExpressibleByStringLiteral {

    init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}

// MARK: - Path Extensions

extension URI.Path {

    static var empty: URI.Path { return .init() }

    mutating func append(_ other: URI.Path) {
        self.components.append(contentsOf: other.components)
    }

    mutating func appending(_ other: URI.Path) -> URI.Path {
        var result = self
        result.append(other)
        return result
    }

    mutating func append(_ elements: [String]) {
        self.components.append(
            contentsOf: elements.flatMap { $0.split(separator: "/").map(String.init) }
        )
    }

    mutating func append(_ elements: String...) {
        self.append(elements)
    }

    mutating func appending(_ elements: [String]) -> URI.Path {
        var result = self
        result.append(elements)
        return result
    }

    mutating func appending(_ elements: String...) -> URI.Path {
        return self.appending(elements)
    }
}

extension URI.Path: RawRepresentable {

    var rawValue: String {
        return "/" + self.components.joined(separator: "/")
    }

    init(rawValue: String) {
        self.components = rawValue.split(separator: "/").map(String.init)
    }
}

extension URI.Path: ExpressibleByArrayLiteral {

    init(arrayLiteral elements: String...) {
        self.components = elements
    }
}

extension URI.Path: ExpressibleByStringLiteral {

    init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

// MARK: - Query Extensions

extension URI.Query.Item: RawRepresentable {

    var rawValue: String {
        return "\(self.name)=\(self.value)"
    }

    init?(rawValue: Self.RawValue) {
        let nameAndValue = rawValue.split(separator: "=")
        guard nameAndValue.count == 2 else { return nil }
        self.name = String(nameAndValue[0])
        self.value = String(nameAndValue[1])
    }
}

extension URI.Query: RawRepresentable {

    var rawValue: String {
        return self.items
            .map { $0.rawValue }
            .joined(separator: String(Self.delimiter))
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }


    init?(rawValue: Self.RawValue) {
        guard let decoded = rawValue.removingPercentEncoding else { return nil }
        self.items = decoded
                .split(separator: Self.delimiter)
                .compactMap { URI.Query.Item(rawValue: String($0)) }
    }
}

extension URI.Query: ExpressibleByArrayLiteral {

    init(arrayLiteral elements: (String, String)...) {
        self.items = elements.map { URI.Query.Item(name: $0, value: $1) }
    }
}

extension URI.Query: ExpressibleByStringLiteral {

    init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}
