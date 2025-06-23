import Foundation
import SwiftNetworkRequest

@GetCollection(url: "https://jsonplaceholder.typicode.com/posts")
@Get(url: "https://jsonplaceholder.typicode.com/posts/:id")
@Post(url: "https://jsonplaceholder.typicode.com/posts")
@Put(url: "https://jsonplaceholder.typicode.com/posts/:id")
@Delete(url: "https://jsonplaceholder.typicode.com/posts/:id")
struct Post: Identifiable, Codable, Equatable {
    @ExcludeFromRequest let id: Int
    var userId: Int
    var title: String
    var body: String
}

extension Post {
    static let draft = Self(id: 0, userId: 0, title: "", body: "")
}
