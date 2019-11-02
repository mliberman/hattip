struct Response: Message {
    var statusCode: Int
    var headers: Headers = []
    var body: MessageBody?
}
