#  Encoding & Decoding
Learn how to implement custom encoding and decoding to your data models 

## Overview

Sometimes, the tools provided by the compiler aren't sufficient, and you may need to apply more advanced encoding or decoding logic to your data models. When you use the **@Get**, **@GetCollection**, **@Post**, or **@Put** macros, the library silently generates inner structs that conform to the **Codable** protocol. This makes it possible to **extend** these generated structs and implement custom encoding or decoding logic as needed. The name of the generated struct for each data model will follow this pattern:

- `@GetCollection` - *ModelName*.GetCollectionResponse
- `@Get` - *ModelName*.GetResponse
- `@Post` - *ModelName*.PostRequestBody
- `@Put` - *ModelName*git .PutRequestBody

Consider a data model like the following, where your `GET` and `POST` requests might require some custom encoding and decoding logic:


```swift
@GetCollection(url: "https://jsonplaceholder.typicode.com/posts")
@Get(url: "https://jsonplaceholder.typicode.com/posts/:id")
@Post(url: "https://jsonplaceholder.typicode.com/posts/:userId", headers: [], queryParams: [])
@Put(url: "https://jsonplaceholder.typicode.com/posts/:id/user/:userId")
@Delete(url: "https://jsonplaceholder.typicode.com/posts/:id")
struct Post: Identifiable, Codable, Equatable {
    @ExcludeFromRequest let id: Int
    @RequestBodyKey("user_id") var userId: Int
    var title: String
    var body: String
}
```

You can apply custom decoding or encoding like so:

```swift
extension Post.GetResponse {
    init(from decoder: any Decoder) throws {
        ...
    }

    func encode(to encoder: any Encoder) throws {
        ...
    }
} 

extension Post.PostRequestBody {
    init(from decoder: any Decoder) throws {
        ...
    }

    func encode(to encoder: any Encoder) throws {
        ...
    }
}

```

This approach allows flexibility to apply custom encoding or decoding for the applied macro.

