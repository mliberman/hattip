import Foundation

public protocol MessageBodyEncodable {
    func encode(using encoder: JSONEncoder) throws -> MessageBody?
}

extension MessageBodyEncodable where Self: Encodable {

    public func encode(using encoder: JSONEncoder) throws -> MessageBody? {
        return try .data(encoder.encode(self))
    }
}

extension Request {

    public struct NoBody: MessageBodyEncodable {
        public func encode(using encoder: JSONEncoder) throws -> MessageBody? {
            return nil
        }
    }

    public struct FileUpload: MessageBodyEncodable {

        public var url: URL

        public func encode(using encoder: JSONEncoder) throws -> MessageBody? {
            return .file(self.url)
        }
    }
}

extension Array: MessageBodyEncodable where Element: Encodable { }

extension Dictionary: MessageBodyEncodable where Key: Encodable, Value: Encodable { }
