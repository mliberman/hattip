protocol Client {
    func send(_ request: Request, completion: @escaping (Result<Response, Error>) -> Void)
}

extension Client {

    func send<C: APIContract>(_ contract: C, completion: @escaping (C.ResultType) -> Void) {
        switch contract.makeRequest() {
        case let .success(request):
            self.send(request) { result in
                switch result {
                case let .success(response):
                    completion(
                        response
                            .decode(
                                C.ResponseBodyType.self,
                                C.ErrorResponseBodyType.self,
                                using: C.decoder
                            )
                            .mapError(MessageError.responseError)
                    )
                case let .failure(error):
                    completion(.failure(.clientError(error)))
                }
            }
        case let .failure(error):
            completion(.failure(.requestError(error)))
        }
    }
}
