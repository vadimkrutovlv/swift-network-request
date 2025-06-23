struct RequestError: Error {
    let message: String
}

enum HTTPMethod: Equatable {
    case get(isList: Bool)
    case post
    case put
    case delete

    var stringValue: String {
        switch self {
        case .get:
            "GET"
        case .post:
            "POST"
        case .put:
            "PUT"
        case .delete:
            "DELETE"
        }
    }

    var macroName: String {
        switch self {
        case .get(let isList):
            isList ? "GetCollection" : "Get"
        case .post:
            "Post"
        case .put:
            "Put"
        case .delete:
            "Delete"
        }
    }
}

enum AccessLevel: String {
    case `public` = "public"
    case `internal` = ""
}
