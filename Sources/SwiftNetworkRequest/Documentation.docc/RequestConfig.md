# RequestConfig – Default Network Configuration
Learn how to provide default headers, query parameters, or an ``HTTPSession`` instance that will be used for every request you make

## Overview

The `RequestConfig` struct defines a centralized configuration for network requests. It allows you to specify **default HTTP headers** and **query parameters** or ``HTTPSession`` conforming instance that will be included in all requests made through your application's networking layer.

The RequestConfig struct defines a centralized configuration for network requests. It allows you to specify default **HTTP headers**, **query parameters**, or an instance conforming to ``HTTPSession``, which will be included in all requests made through your application's networking layer.

This struct is designed to work with dependency injection via Swift's [@Dependency](https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/) property wrapper, and it conforms to `Sendable` for use in concurrent environments.


## Properties

### defaultHeaders

Default HTTP headers that will be included with every request.

---

### defaultQueryParams

Default query parameters appended to every request URL.

---

### urlSession

The underlying HTTP session used for performing network requests. This is injected automatically via dependencies.

```swift
@Dependency(\.networkRequestSession) var networkRequestSession
```

## Configuration Options

### Global Configuration (Per App)

You can override the default ``RequestConfig`` globally for your entire app using the **prepareDependencies** closure:

```swift
struct MyApp: App {
    init() {
        prepareDependencies {
            $0.requestConfig = RequestConfig(
                defaultHeaders: [KeyValuePair(key: "Authorization", value: "Bearer token123")],
                defaultQueryParams: [KeyValuePair(key: "primaryLocale", value: "en-US")]
            )
        }
    }
}
```

⚠️ Note: Once you configure RequestConfig using prepareDependencies, it becomes the default for the lifetime of the app, and it **cannot be overridden per request** anymore.


### Per-Request Override (Optional)

If you're not using **prepareDependencies** to override ``RequestConfig``, you can still customize it per request using the withDependencies closure:

```swift
withDependencies {
    $0.requestConfig = RequestConfig(
        defaultHeaders: [KeyValuePair(key: "X-Trace-ID", value: "debug-123")],
        defaultQueryParams: [KeyValuePair(key: "debug", value: "true")]
    )
} operation: {
    // Perform your request here
}
```

## Best Practices

- Use `prepareDependencies` when your app needs a consistent global config.
- Use `withDependencies` when you need flexibility for testing, debugging, or request-specific customization.


## Testing 

You can still have both a global configuration for your app using the **prepareDependencies** closure and the flexibility of **withDependencies** in your tests. To achieve this, you should detect when your code is running in a test environment and conditionally skip **prepareDependencies** in that case.


```swift
struct MyApp: App {
    // Utility to detect if the current process is running under XCTest
    var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    init() {
        if !isTestSuiteRunning { 
            prepareDependencies {
                $0.requestConfig = RequestConfig(
                    defaultHeaders: [KeyValuePair(key: "Authorization", value: "Bearer token123")],
                    defaultQueryParams: [KeyValuePair(key: "primaryLocale", value: "en-US")]
                )
            }
        }       
    }
}
```

### Overriding url Session in your tests

You can substitute your own mock version of **URLSession** in tests. This library relies on the `swift-dependencies` framework, which allows you to override the **networkRequestSession** dependency during testing.
Please note that, by default, the library provides only the liveValue implementation of the dependency. To learn more about the swift-dependencies framework, please visit the [official documentation website](https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/livepreviewtest).

The **networkRequestSession** dependency returns an instance conforming to the ``HTTPSession`` protocol, which includes the most commonly used methods from **URLSession**.

If you find that something is missing, please open a GitHub issue — we’ll do our best to help.

The example below shows how to implement your own mock version of **URLSession** and override **networkRequestSession** in your tests, as well as provides an example test case:

```swift
import Foundation
import SwiftNetworkRequest

// Example of a mock HTTPSession for testing
struct HTTPSessionMock: HTTPSession { 
    enum ResponseStatus: Int {
        case success = 200
        case serverError = 500
    }

    let result: (@Sendable (URLRequest) throws -> (Data, ResponseStatus))
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {    
        let (data, statusCode) = try result(request)
    
        guard let response = HTTPURLResponse(
            url: .applicationDirectory,
            statusCode: statusCode.rawValue,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw NSError(domain: "Couldn't construct a valid URLResponse", code: 0)
        }

        return try (data, response)
    }
    
    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        ...
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        ...
    }    
}

func testGetPosts() {
    let expectedResults: [Post] = [
        .init(id: 1, userId: 1, title: "Test 1", body: "Test 1"),
        .init(id: 2, userId: 2, title: "Test 2", body: "Test 2")
    ]

    let session = HTTPSessionMock { request in
        // Assert various parameters of the request
        let containsCustomHeaders = request.allHTTPHeaderFields?.contains {
            $0.key == "myHeader" && $0.value == "myValue"
        }

        #expect(request.httpMethod == "GET")
        #expect(containsCustomHeaders != nil)
        #expect(request.url?.absoluteString == "https://myApiUr.com/posts?myQueryParam=testValue&myAnotherParam=anotherTestValue")
        
        return try (expectedResults.toData, .success)
    }

    // Override the dependency in a test
    try await withDependencies {
        $0.networkRequestSession = session
        $0.requestConfig = .init(
            defaultHeaders: [.init(key: "myHeader", value: "myValue")],
            defaultQueryParams: [
                .init(key: "myQueryParam", value: "testValue"),
                .init(key: "myAnotherParam", value: "anotherTestValue"),
            ]
        )
    } operation: {
        let result = try await Post.get()
        
        #expect(result == expectedResults)
    }
}
```
