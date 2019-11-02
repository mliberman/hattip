struct HatTipError: Error {
    var reason: String
}

extension HatTipError: CustomStringConvertible {
    var description: String { return self.reason }
}
