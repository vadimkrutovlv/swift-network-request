# ``SwiftNetworkRequest``

![Static Badge](https://img.shields.io/badge/Swift-6.2%20%7C%206.1%20%7C%206.0-blue?logo=swift)
![Static Badge](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-blue?logo=apple)


A lightweight and developer-friendly Swift framework for performing RESTful network requests with minimal boilerplate code on Apple platforms.

- [Overview](#overview)
- [Requirements](#requirements)
- [Dependencies](#Dependencies)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Documentation](#documentation)


## Overview

This framework abstracts away the complexities of URL construction, parameter encoding, headers, and response parsing—making it easy to interact with REST APIs using concise and readable syntax.
It abstracts away the complexities of:

- URL construction with path parameters
- Header and query parameter configuration
- JSON encoding/decoding
- Request body customization
- Response parsing and error handling

By using macros like `@Get`, `@GetCollection` `@Post`, `@Put`, and `@Delete`, you can define network behavior declaratively—directly alongside your model types. The result is a drastically simplified API layer that stays **readable**, **testable**, and **type-safe**.



## Requirements

The library uses the Swift 6.0 toolchain and supports the following platforms:

- iOS 15 and higher
- macOS 13 and higher
- tvOS 13 and higher
- watchOS 8 and higher


## Dependencies

The library depends on the following external libraries and their transitive dependencies:

- [swift-dependencies](https://github.com/pointfreeco/swift-dependencies)
- [swift-macro-testing](https://github.com/pointfreeco/swift-macro-testing)

## Getting Started

Library lets you define REST API interactions directly on your models using macros like `@Get`, `@GetCollection` `@Post`, `@Put`, and `@Delete`. This guide walks you through the essentials to get up and running quickly.


Use the appropriate macro to define the request you want to make.  
For example, to create a new blog post, you can define the model as follows:


```swift
@Post(url: "https://api.example.com/posts")
struct Post {
    @ExcludeFromRequest let id: Int
    var userId: Int
    var title: String
    var body: String
}
```

You can now use the generated `post()` method without writing boilerplate code:

```swift
var post = Post(userId: 1, title: "Hello World", body: "Content here...")
try await post.post()
```

### Customize Your Requests

#### Exclude properties from the request body:

Use `@ExcludeFromRequest` to prevent a property from being included in the JSON body of the request. This is useful for fields like id, createdAt, or any other server-managed or read-only values.

```swift
@ExcludeFromRequest let id: Int
@ExcludeFromRequest let createdAt: Date
```

In the example below, the `id` property is excluded from the POST request body.

#### Rename JSON keys in the request body

Use `@RequestBodyKey("your_key")` to map a Swift property to a specific key in the request JSON:

```swift
@RequestBodyKey("user_id") var userId: Int
```

#### Add headers or query parameters
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

## Installation

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

### Using Xcode

1. Open your Xcode project.
2. Navigate to **File > Add Packages...**
3. Enter the following URL in the search field: https://github.com/vadimkrutovlv/swift-network-request
4. Choose the latest available version (starting from `0.1.0` or later).
5. Click **Add Package** to finish.

### Documentation 

The latest documentation for the library APIs is available [here](https://swiftpackageindex.com/vadimkrutovlv/swift-network-request/main/documentation/swiftnetworkrequest).
