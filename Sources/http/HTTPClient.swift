protocol HTTPClient {
    func send(_ request: HTTPRequest, completion: @escaping () -> Void)
}


