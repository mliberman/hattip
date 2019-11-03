import Foundation

protocol MessageBodyEncodable {
    func encode(using encoder: JSONEncoder) throws -> MessageBody?
}

extension MessageBodyEncodable where Self: Encodable {

    func encode(using encoder: JSONEncoder) throws -> MessageBody? {
        return try .data(encoder.encode(self))
    }
}

extension Request {

    struct NoBody: MessageBodyEncodable {
        func encode(using encoder: JSONEncoder) throws -> MessageBody? {
            return nil
        }
    }

    struct FileUpload: MessageBodyEncodable {

        var url: URL

        func encode(using encoder: JSONEncoder) throws -> MessageBody? {
            return .file(self.url)
        }
    }
}

extension Array: MessageBodyEncodable where Element: Encodable { }

extension Dictionary: MessageBodyEncodable where Key: Encodable, Value: Encodable { }
