import Foundation

enum HTTPMessageBody {
    case file(URL)
    case data(Data)
}

protocol HTTPMessage {
    var headers: HTTPHeaders { get set }
    var body: HTTPMessageBody? { get set }
}

extension HTTPMessageBody {

    func read() throws -> Data {
        switch self {
        case let .data(data):
            return data
        case let .file(file):
            return try Data(contentsOf: file)
        }
    }
}
