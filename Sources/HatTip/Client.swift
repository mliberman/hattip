protocol Client {
    func send(_ request: Request, completion: @escaping () -> Void)
}
