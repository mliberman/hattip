import Foundation

public enum MessageBody {
    case file(URL)
    case data(Data)
}

extension MessageBody {

    public func read() throws -> Data {
        switch self {
        case let .data(data):
            return data
        case let .file(file):
            return try Data(contentsOf: file)
        }
    }
}
