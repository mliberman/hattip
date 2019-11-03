public struct HatTipError: Error {
    public var reason: String
}

extension HatTipError: CustomStringConvertible {
    public var description: String { return self.reason }
}
