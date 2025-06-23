# Fetching Resource
Learn how to fetch a single resource or a list of resources.

## Overview

The **@Get** and **@GetCollection** macros allow you to fetch data from REST APIs via HTTP **GET** requests with minimal boilerplate. These macros are designed to work seamlessly with model types and automatically handle path parameters, query strings, and response decoding.


## @Get – Fetch a Single Resource

Use the **@Get** macro to generate a static method for fetching a single resource from an endpoint.

### Basic Usage

```swift
@Get(url: "https://api.example.com/posts/:id")
struct Post {
    let id: Int
    let title: String
    let body: String
}
```

The macro generates the following method, which automatically fills in the path parameter as a method argument from the URL, if one is specified:

```swift
static func get(
    id: Int
    dynamicHeaders: [KeyValuePair] = [], 
    dynamicQueryParameters: [KeyValuePair] = []
) async throws -> Post
```

You can use this method to perform a network request without writing boilerplate code:

```swift 
let post = try await Post.get(id: 42)
print(post.title)
```

## @GetCollection – Fetch a List of Resources
Use the **@GetCollection** macro to fetch an array of resources from an endpoint.

### Basic Usage

```swift
@GetCollection(url: "https://api.example.com/posts")
struct Post {
    let id: Int
    let title: String
    let body: String
}
```

The macro generates the following method:

```swift
static func get(
    dynamicHeaders: [KeyValuePair] = [], 
    dynamicQueryParameters: [KeyValuePair] = []
) async throws -> [Post]
```

You can use this method to perform a network request without writing boilerplate code:

```swift 
let posts = try await Post.get()
print(posts.count)
```

### With Dynamic Headers

```swift
let customHeaders = [
    KeyValuePair(key: "X-Custom-Header", value: "CustomValue"),
    KeyValuePair(key: "Content-Type", value: "application/json")
]

let posts = try await Post.get(dynamicHeaders: customHeaders)
```

### With Dynamic Query Parameters

```swift
let queryParams = [
    KeyValuePair(key: "version", value: "1.0"),
    KeyValuePair(key: "format", value: "json")
]

let posts = try await Post.get(dynamicQueryParams: queryParams)
```

### With Both Dynamic Headers and Query Parameters

```swift
let posts = try await Post.get(
    dynamicHeaders: customHeaders,
    dynamicQueryParams: queryParams
)
```

Additionally, you can define default headers for every request by overriding the **request configuration** or **default authorization** properties. To learn more, refer to the <doc:RequestConfig> and <doc:Authorization> documentation.


## Path Parameters
Path parameters in the URL (e.g., :id, :userId) are automatically mapped to the method parameters. The macro replaces these placeholders with the values you provide when calling the method.

Consider this data model:

```swift
@Get(url: "https://api.example.com/users/:userId/posts/:postId")
struct Post {
    let postId: Int
    let userId: Int
    let title: String
    let body: String
}
```

The applied macro will generate following method: 

```swift
static func get(userId: Int, postId: Int) async throws -> Post
```

Which you can use like this:

```swift
let post = try await Post.get(userId: 10, postId: 99)
```

This behavior ensures strong type safety and removes the need to manually construct URLs or inject path parameters yourself.

For more advanced use cases like query parameters or headers, you may consider using ``Get(url:headers:queryParams:)`` or ``GetCollection(url:headers:queryParams:)`` along with customizable macros or configuration injection.
