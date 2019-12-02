import Foundation

// MARK: - BasicError

public struct BasicError: Error, CustomStringConvertible {

    public var reason: String
    public var underlyingError: Error?
    public var file: String
    public var line: UInt

    public init(
        reason: String,
        underlyingError: Error? = nil,
        file: String = #file,
        line: UInt = #line
        ) {

        self.reason = reason
        self.underlyingError = underlyingError
        self.file = file
        self.line = line
    }

    public var filename: String {
        return URL(string: self.file)!.lastPathComponent
    }

    /// See `CustomStringConvertible`.
    public var description: String {
        let typeName = self.underlyingError.map { String(describing: type(of: $0)) }
        return "\(typeName.map { "[\($0)] " } ?? "")\(reason) (\(self.filename):L\(self.line))"
    }
}

// MARK: - Unknown Errors

extension BasicError {

    internal init(
        unknownError error: NSError,
        file: String = #file,
        line: UInt = #line
        ) {

        self.init(
            reason: "\(error.domain).\(error.code) occurred: \(error.debugDescription)",
            underlyingError: error,
            file: file,
            line: line
        )
    }
}

// MARK: - Encoding Errors

extension BasicError {

    internal init(
        encodingError error: EncodingError,
        file: String = #file,
        line: UInt = #line
        ) {

        self.init(
            reason: error.reason,
            underlyingError: error,
            file: file,
            line: line
        )
    }
}

extension EncodingError {

    fileprivate var reason: String {
        switch self {
        case let .invalidValue(_, context):
            return context.debugDescription
        @unknown default:
            return self.failureReason ?? "Unknown error"
        }
    }
}

// MARK: - File Errors

extension BasicError {

    internal init(
        fileError error: NSError,
        file: String = #file,
        line: UInt = #line
        ) {

        self.init(
            reason: "\(Self.stringifyCode(forFileError: error)) occurred",
            underlyingError: error,
            file: file,
            line: line
        )
    }

    private static func stringifyCode(forFileError error: NSError) -> String {
        switch error.code {
        case NSFileNoSuchFileError:
            return "NSFileNoSuchFileError"
        case NSFileLockingError:
            return "NSFileLockingError"
        case NSFileReadUnknownError:
            return "NSFileReadUnknownError"
        case NSFileReadNoPermissionError:
            return "NSFileReadNoPermissionError"
        case NSFileReadInvalidFileNameError:
            return "NSFileReadInvalidFileNameError"
        case NSFileReadCorruptFileError:
            return "NSFileReadCorruptFileError"
        case NSFileReadNoSuchFileError:
            return "NSFileReadNoSuchFileError"
        case NSFileReadInapplicableStringEncodingError:
            return "NSFileReadInapplicableStringEncodingError"
        case NSFileReadUnsupportedSchemeError:
            return "NSFileReadUnsupportedSchemeError"
        case NSFileReadTooLargeError:
            return "NSFileReadTooLargeError"
        case NSFileReadUnknownStringEncodingError:
            return "NSFileReadUnknownStringEncodingError"
        case NSFileWriteUnknownError:
            return "NSFileWriteUnknownError"
        case NSFileWriteNoPermissionError:
            return "NSFileWriteNoPermissionError"
        case NSFileWriteInvalidFileNameError:
            return "NSFileWriteInvalidFileNameError"
        case NSFileWriteFileExistsError:
            return "NSFileWriteFileExistsError"
        case NSFileWriteInapplicableStringEncodingError:
            return "NSFileWriteInapplicableStringEncodingError"
        case NSFileWriteUnsupportedSchemeError:
            return "NSFileWriteUnsupportedSchemeError"
        case NSFileWriteOutOfSpaceError:
            return "NSFileWriteOutOfSpaceError"
        case NSFileWriteVolumeReadOnlyError:
            return "NSFileWriteVolumeReadOnlyError"
        default:
            return "\(error.domain).\(error.code)"
        }
    }
}

// MARK: - URL Errors

extension BasicError {

    internal init(
        urlError error: NSError,
        file: String = #file,
        line: UInt = #line
        ) {

        self.init(
            reason: "\(Self.stringifyCode(forUrlError: error)) occurred",
            underlyingError: error,
            file: file,
            line: line
        )
    }

    private static func stringifyCode(forUrlError error: NSError) -> String {
        switch error.code {
        case NSURLErrorUnknown:
            return "NSURLErrorUnknown"
        case NSURLErrorCancelled:
            return "NSURLErrorCancelled"
        case NSURLErrorBadURL:
            return "NSURLErrorBadURL"
        case NSURLErrorTimedOut:
            return "NSURLErrorTimedOut"
        case NSURLErrorUnsupportedURL:
            return "NSURLErrorUnsupportedURL"
        case NSURLErrorCannotFindHost:
            return "NSURLErrorCannotFindHost"
        case NSURLErrorCannotConnectToHost:
            return "NSURLErrorCannotConnectToHost"
        case NSURLErrorNetworkConnectionLost:
            return "NSURLErrorNetworkConnectionLost"
        case NSURLErrorDNSLookupFailed:
            return "NSURLErrorDNSLookupFailed"
        case NSURLErrorHTTPTooManyRedirects:
            return "NSURLErrorHTTPTooManyRedirects"
        case NSURLErrorResourceUnavailable:
            return "NSURLErrorResourceUnavailable"
        case NSURLErrorNotConnectedToInternet:
            return "NSURLErrorNotConnectedToInternet"
        case NSURLErrorRedirectToNonExistentLocation:
            return "NSURLErrorRedirectToNonExistentLocation"
        case NSURLErrorBadServerResponse:
            return "NSURLErrorBadServerResponse"
        case NSURLErrorUserCancelledAuthentication:
            return "NSURLErrorUserCancelledAuthentication"
        case NSURLErrorUserAuthenticationRequired:
            return "NSURLErrorUserAuthenticationRequired"
        case NSURLErrorZeroByteResource:
            return "NSURLErrorZeroByteResource"
        case NSURLErrorCannotDecodeRawData:
            return "NSURLErrorCannotDecodeRawData"
        case NSURLErrorCannotDecodeContentData:
            return "NSURLErrorCannotDecodeContentData"
        case NSURLErrorCannotParseResponse:
            return "NSURLErrorCannotParseResponse"
        case NSURLErrorAppTransportSecurityRequiresSecureConnection:
            return "NSURLErrorAppTransportSecurityRequiresSecureConnection"
        case NSURLErrorFileDoesNotExist:
            return "NSURLErrorFileDoesNotExist"
        case NSURLErrorFileIsDirectory:
            return "NSURLErrorFileIsDirectory"
        case NSURLErrorNoPermissionsToReadFile:
            return "NSURLErrorNoPermissionsToReadFile"
        case NSURLErrorDataLengthExceedsMaximum:
            return "NSURLErrorDataLengthExceedsMaximum"
        case NSURLErrorFileOutsideSafeArea:
            return "NSURLErrorFileOutsideSafeArea"
        case NSURLErrorSecureConnectionFailed:
            return "NSURLErrorSecureConnectionFailed"
        case NSURLErrorServerCertificateHasBadDate:
            return "NSURLErrorServerCertificateHasBadDate"
        case NSURLErrorServerCertificateUntrusted:
            return "NSURLErrorServerCertificateUntrusted"
        case NSURLErrorServerCertificateHasUnknownRoot:
            return "NSURLErrorServerCertificateHasUnknownRoot"
        case NSURLErrorServerCertificateNotYetValid:
            return "NSURLErrorServerCertificateNotYetValid"
        case NSURLErrorClientCertificateRejected:
            return "NSURLErrorClientCertificateRejected"
        case NSURLErrorClientCertificateRequired:
            return "NSURLErrorClientCertificateRequired"
        case NSURLErrorCannotLoadFromNetwork:
            return "NSURLErrorCannotLoadFromNetwork"
        case NSURLErrorCannotCreateFile:
            return "NSURLErrorCannotCreateFile"
        case NSURLErrorCannotOpenFile:
            return "NSURLErrorCannotOpenFile"
        case NSURLErrorCannotCloseFile:
            return "NSURLErrorCannotCloseFile"
        case NSURLErrorCannotWriteToFile:
            return "NSURLErrorCannotWriteToFile"
        case NSURLErrorCannotRemoveFile:
            return "NSURLErrorCannotRemoveFile"
        case NSURLErrorCannotMoveFile:
            return "NSURLErrorCannotMoveFile"
        case NSURLErrorDownloadDecodingFailedMidStream:
            return "NSURLErrorDownloadDecodingFailedMidStream"
        case NSURLErrorDownloadDecodingFailedToComplete:
            return "NSURLErrorDownloadDecodingFailedToComplete"
        case NSURLErrorInternationalRoamingOff:
            return "NSURLErrorInternationalRoamingOff"
        case NSURLErrorCallIsActive:
            return "NSURLErrorCallIsActive"
        case NSURLErrorDataNotAllowed:
            return "NSURLErrorDataNotAllowed"
        case NSURLErrorRequestBodyStreamExhausted:
            return "NSURLErrorRequestBodyStreamExhausted"
        case NSURLErrorBackgroundSessionRequiresSharedContainer:
            return "NSURLErrorBackgroundSessionRequiresSharedContainer"
        case NSURLErrorBackgroundSessionInUseByAnotherProcess:
            return "NSURLErrorBackgroundSessionInUseByAnotherProcess"
        case NSURLErrorBackgroundSessionWasDisconnected:
            return "NSURLErrorBackgroundSessionWasDisconnected"
        default:
            return "\(error.domain).\(error.code)"
        }
    }
}

// MARK: - Decoding Errors

extension BasicError {

    internal init(
        decodingError error: DecodingError,
        file: String = #file,
        line: UInt = #line
        ) {

        self.init(
            reason: error.reason,
            underlyingError: error,
            file: file,
            line: line
        )
    }
}

extension DecodingError {

    fileprivate var reason: String {
        switch self {
        case let .dataCorrupted(context),
             let .keyNotFound(_, context),
             let .typeMismatch(_, context),
             let .valueNotFound(_, context):
            return "[ \(context.codingPath.map({ $0.stringValue }).joined(separator: " > ")) ]: \(context.debugDescription)"
        @unknown default:
            return self.failureReason ?? "Unknown error"
        }
    }
}
