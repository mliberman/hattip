import Foundation

public protocol MessageBodyEncodable {
    func encode(using encoder: JSONEncoder) -> Result<MessageBody?, BasicError>
}

extension MessageBodyEncodable where Self: Encodable {

    public func encode(using encoder: JSONEncoder) -> Result<MessageBody?, BasicError> {
        do {
            return try .success(.data(encoder.encode(self)))
        } catch let error as EncodingError {
            return .failure(.init(encodingError: error))
        } catch let error as NSError {
            return .failure(.init(unknownError: error))
        }
    }
}

extension Request {

    public struct NoBody: MessageBodyEncodable {

        public init() { }

        public func encode(using encoder: JSONEncoder) -> Result<MessageBody?, BasicError> {
            return .success(nil)
        }
    }

    public struct FileUpload: MessageBodyEncodable {

        public var url: URL

        public init(url: URL) {
            self.url = url
        }

        public func encode(using encoder: JSONEncoder) -> Result<MessageBody?, BasicError> {
            return .success(.file(self.url))
        }
    }
}

extension Array: MessageBodyEncodable where Element: Encodable { }

extension Dictionary: MessageBodyEncodable where Key: Encodable, Value: Encodable { }
