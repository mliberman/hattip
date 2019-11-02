import Foundation

extension HTTPURLResponse {

    var headers: Headers {
        return Headers(
            headers: self.allHeaderFields
                .compactMap { (anyName, anyValue) in
                    guard
                        let name = anyName as? String,
                        let value = anyValue as? String
                        else { return nil }
                    return Header(name: name, value: value)
                }
        )
    }
}
