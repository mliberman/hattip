public struct HatTipError: Error {

    public var reason: String

    public init(reason: String) {
        self.reason = reason
    }
}

extension HatTipError: CustomStringConvertible {
    public var description: String { return self.reason }
}
