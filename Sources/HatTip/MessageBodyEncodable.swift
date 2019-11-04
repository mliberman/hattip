import Foundation

/// A protocol that enables types to be encoded to JSON
/// HTTP message request bodies.
public protocol MessageBodyEncodable {

    /// Encodes the receiver with the provided `JSONEncoder`.
    ///
    /// - Parameter encoder: The encoder to use.
    /// - Returns: The receiver encoded as JSON data, or the error
    /// thrown during encoding.
    /// - Note: A `MessageBody` can be empty by providing an empty `Data`
    /// instance.
    func encode(using encoder: JSONEncoder) -> Result<MessageBody, BasicError>
}

/// Automatic `MessageBodyEncodable` conformance for `Encodable` types.
extension MessageBodyEncodable where Self: Encodable {

    public func encode(using encoder: JSONEncoder) -> Result<MessageBody, BasicError> {
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

    /// An empty structure that "encodes" to an empty body.
    public struct NoBody: MessageBodyEncodable {

        public init() { }

        public func encode(using encoder: JSONEncoder) -> Result<MessageBody, BasicError> {
            return .success(.data(.init()))
        }
    }

    /// A structure containing a URL that "encodes" itself to a
    /// `MessageBody.file` for file uploads.
    public struct FileUpload: MessageBodyEncodable {

        public var url: URL

        public init(url: URL) {
            self.url = url
        }

        public func encode(using encoder: JSONEncoder) -> Result<MessageBody, BasicError> {
            return .success(.file(self.url))
        }
    }
}

extension Array: MessageBodyEncodable where Element: Encodable { }

extension Dictionary: MessageBodyEncodable where Key: Encodable, Value: Encodable { }
