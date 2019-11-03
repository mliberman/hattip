import Foundation

public enum MessageBody {
    case file(URL)
    case data(Data)
}

public protocol Message {
    var headers: Headers { get set }
    var body: MessageBody? { get set }
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
