import Foundation

extension URLSession: Client {

    public func send(_ request: Request, completion: @escaping (Result<Response, BasicError>) -> Void) {
        switch request.body {
        case .none, .some(.data):
            switch request.responseBodyHint {
            case .data:
                self.sendViaDataTask(request, completion: completion)
            case let .file(url):
                self.sendViaDownloadTask(request, to: url, completion: completion)
            }
        case let .some(.file(url)):
            self.sendViaUploadTask(request, from: url, completion: completion)
        }
    }

    private func sendViaDataTask(
        _ request: Request,
        completion: @escaping (Result<Response, BasicError>) -> Void
        ) {

        let task = self.dataTask(with: request.urlRequest) { (data, response, error) in
            completion(
                Response.make(
                    data: data,
                    response: response,
                    error: error as NSError?
                )
            )
        }
        task.resume()
    }

    private func sendViaDownloadTask(
        _ request: Request,
        to destination: URL?,
        completion: @escaping (Result<Response, BasicError>) -> Void
        ) {

        let task = self.downloadTask(with: request.urlRequest) { (tmpUrl, response, error) in
            guard let tmpUrl = tmpUrl else {
                return completion(
                    Response.make(
                        url: nil,
                        response: response,
                        error: error as NSError?
                    )
                )
            }
            do {
                let dst = destination ?? FileManager.default
                    .temporaryDirectory
                    .appendingPathComponent(UUID().uuidString, isDirectory: false)
                try? FileManager.default.removeItem(at: dst)
                try FileManager.default.moveItem(at: tmpUrl, to: dst)
                completion(
                    Response.make(
                        url: dst,
                        response: response,
                        error: error as NSError?
                    )
                )
            } catch {
                completion(.failure(.init(fileError: error as NSError)))
            }
        }
        task.resume()
    }

    private func sendViaUploadTask(
        _ request: Request,
        from source: URL,
        completion: @escaping (Result<Response, BasicError>) -> Void
        ) {

        let task = self.uploadTask(with: request.urlRequest, fromFile: source) { (data, response, error) in
            completion(
                Response.make(
                    data: data,
                    response: response,
                    error: error as NSError?
                )
            )
        }
        task.resume()
    }
}
