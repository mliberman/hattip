import Foundation

extension HTTPURLResponse {

    var headers: HTTPHeaders {
        return HTTPHeaders(
            headers: self.allHeaderFields
                .compactMap { (anyName, anyValue) in
                    guard
                        let name = anyName as? String,
                        let value = anyValue as? String
                        else { return nil }
                    return HTTPHeader(name: name, value: value)
                }
        )
    }
}
