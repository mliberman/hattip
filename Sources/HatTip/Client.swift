public protocol Client {
    func send(_ request: Request, completion: @escaping (Result<Response, Error>) -> Void)
}
