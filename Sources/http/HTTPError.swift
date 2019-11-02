struct HTTPError: Error {
    var reason: String
}

extension HTTPError: CustomStringConvertible {
    var description: String { return self.reason }
}
