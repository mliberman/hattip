extension Client {

    /// Executes the given `contract` by sending its request and attempting to decode
    /// its response.
    /// - Parameters:
    ///   - contract: The `APIContract` whose request will be sent.
    ///   - completion: A closure to execute once the `contract`'s execution either fails
    ///   or finishes successfully.
    public func send<C: APIContract>(_ contract: C, completion: @escaping (C.Result) -> Void) {
        switch contract.makeRequest() {
        case let .success(request):
            self.send(request) { result in
                switch result {
                case let .success(response):
                    contract.didReceiveResponse(response, for: request)
                    completion(
                        C.flatten(
                            .success(
                                response.decode(
                                    C.ResponseBody.self,
                                    C.ErrorResponseBody.self,
                                    using: C.decoder
                                )
                            )
                        )
                    )
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        case let .failure(error):
            completion(.failure(error))
        }
    }
}
