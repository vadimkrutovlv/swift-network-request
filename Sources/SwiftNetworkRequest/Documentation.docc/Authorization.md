#  Provide default authorization header
Learn how to provide a default authorization header that will be used for every request you make

## Overview

Many applications implement a centralized mechanism for retrieving API authorization credentials and appending them as headers to outgoing requests. This library optionally allows the configuration of a centralized asynchronous function that returns a ``KeyValuePair`` instance representing the authorization header. If provided, the returned key-value pair is automatically appended to the request headers.

Because the library uses the [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) framework, this function can be overridden either globally or on a per-request basis.


## Global Override (Recommended)

The recommended approach for setting a global override is to configure it at the earliest stage of the application lifecycle—typically at the application's entry point.


```swift
import Dependencies

struct MyApp: App {
    init() {
        prepareDependencies {
            $0.defaultAuthorization.getAuthorizationHeader = {
                // Make a request...

                return .init(key: "Bearer", value: "Token")
            }
        }
    }
}
```

⚠️ Note: Once you override **getAuthorizationHeader** function using **prepareDependencies**, it becomes the default for the lifetime of the app, and it **cannot be overridden per request** anymore.


## Per-Request Override

If you're not using `prepareDependencies` to override **getAuthorizationHeader** function, you can still customize it per request using the withDependencies closure:

```swift
withDependencies {
    $0.defaultAuthorization.getAuthorizationHeader = {
        // Make a request...

        return .init(key: "Bearer", value: "Token")
    }
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
                $0.defaultAuthorization.getAuthorizationHeader = {
                    // Make a request...
                    return .init(key: "Bearer", value: "Token")
                }
            }
        }       
    }
}
```

### Overriding authorization header in your tests

The library provides a default implementation of testValue for the `defaultAuthorization` dependency, but this value can still be overridden if needed, like so:

```swift
func myTestCase() {
    withDependencies {
        $0.defaultAuthorization.getAuthorizationHeader = {
            return .init(key: "Test Bearer Key", value: "Test Token")
        }
    } operation: {
        // Perform your assertions here...
    }
}
```
