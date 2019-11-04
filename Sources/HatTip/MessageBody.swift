import Foundation

/// The contents of an HTTP message's body.
public enum MessageBody {

    /// The HTTP message's body is stored in memory as `Data`.
    case data(Data)

    /// The HTTP message's body is stored on disk at the associated `URL`.
    ///
    /// This is useful for large file uploads or downloads, e.g. when using a
    /// `URLSessionDownloadTask` or `URLSessionUploadTask`.
    case file(URL)

    /// Returns the content of the message body as `Data`, either by simply returning
    /// the associated `Data`, or by reading the contents of the associated file `URL`.
    ///
    /// - Throws: Rethrows any error thrown by `Data.init(contentsOf:)`.
    /// - Returns: The data content of the message body.
    public func read() throws -> Data {
        switch self {
        case let .data(data):
            return data
        case let .file(file):
            return try Data(contentsOf: file)
        }
    }
}
