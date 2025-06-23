
# Quick Start Guide
Learn the basics of getting started with the library before diving deep into all of its features.

## Overview

This library lets you define REST API interactions directly on your data models using macros like **@Get**, **@GetCollection**, **@Post**, **@Put**, and **@Delete**. This guide walks you through the essentials to get up and running quickly.


## 1. Requirements

- Swift 6.0+
- Xcode 15+
- iOS 15+
- macOS 13+
- watchOS 6+ 
- Uses [`swift-dependencies`](https://github.com/pointfreeco/swift-dependencies) for testable dependency injection


## 2. Installation

Add the package to your project using Swift Package Manager:

```swift
let package = Package(
    dependencies: [
        .package(
            url: "https://github.com/vadimkrutovlv/swift-network-request",
            from: "0.1.0"
        ),
    ],
    targets: [
        .target(
            name: "<your-target-name>",
            dependencies: [
                .product(name: "SwiftNetworkRequest", package: "swift-network-request")
            ]
        )
    ]
)
```

## 3. Define Your Model

Use the appropriate macro to define the request you want to make. For example, to create a new blog post, you can define the data model as follows:

```swift
@Post(url: "https://api.example.com/posts")
struct Post {
    @ExcludeFromRequest let id: Int
    var userId: Int
    var title: String
    var body: String
}
```

## 4. Send a Request

You can now use the generated **post()** method without writing boilerplate code:

```swift
var post = Post(userId: 1, title: "Hello World", body: "Content here...")
try await post.post()
```


## 5. Customize Your Requests

### Exclude properties from the request body:

Use **@ExcludeFromRequest** to prevent a property from being included in the JSON body of the request. This is useful for fields like id, createdAt, or any other server-managed or read-only values.

```swift
@ExcludeFromRequest let id: Int
@ExcludeFromRequest let createdAt: Date
```

In the example below, the **id** property is excluded from the POST request body.

### Rename JSON keys in the request body

Use **@RequestBodyKey("your_key")** to map a Swift property to a specific key in the request JSON:

```swift
@RequestBodyKey("user_id") var userId: Int
```

### Add headers or query parameters
Customize headers and query parameters per request:

```swift 
@Put(
    url: "https://api.example.com/users/:id",
    headers: [KeyValuePair(key: "Content-Type", value: "application/json")],
    queryParams: [KeyValuePair(key: "notify", value: "true")]
)
struct User {
    @ExcludeFromRequest let id: Int // Excluded from request body, but used in URL path (:id)
    var name: String
    var email: String
}
```

## Supported Macros

- ``Get(url:headers:queryParams:)`` – Fetch a single resource  
- ``GetCollection(url:headers:queryParams:)`` – Fetch a list of resources  
- ``Post(url:headers:queryParams:)`` – Create a new resource  
- ``Put(url:headers:queryParams:)`` – Update an existing resource  
- ``Delete(url:headers:queryParams:)`` – Delete a resource  

## Learn more
Check out the documentation for more examples and API reference.
