import Dependencies
import Foundation

/// Configuration object that defines default networking parameters for HTTP requests.
///
/// `RequestConfig` holds common settings such as default HTTP headers and query parameters
/// that should be included in all network requests. It also provides access to the
/// current `HTTPSession` used to perform requests, which is resolved via dependency injection.
///
/// This struct is `Sendable` to support concurrency and safe usage in async contexts.
///
/// ## Properties
///
/// - `defaultHeaders`: An array of `KeyValuePair` representing HTTP headers to include by default in every request.
/// - `defaultQueryParams`: An array of `KeyValuePair` representing query parameters to append by default in every request.
/// - `urlSession`: The HTTP session used to perform network requests. This value is automatically resolved
///   via the `networkRequestSession` dependency and typically backed by `URLSession`.
///
/// ## Usage
///
/// You can create a `RequestConfig` instance with your preferred default headers and query parameters:
///
/// ```swift
/// let config = RequestConfig(
///     defaultHeaders: [KeyValuePair.contentTypeJson],
///     defaultQueryParams: [KeyValuePair(key: "api_key", value: "123456")]
/// )
/// ```
///
/// The `urlSession` property is automatically wired to the dependency system, so you usually don’t need to set it manually.
///
/// ## Initialization
///
/// - Parameters:
///   - defaultHeaders: Optional default headers to include in requests (default: empty).
///   - defaultQueryParams: Optional default query parameters to append in requests (default: empty).
///
public struct RequestConfig: Sendable {
    /// Default HTTP headers included in all requests.
    public let defaultHeaders: [KeyValuePair]
    
    /// Default query parameters appended to all request URLs.
    public let defaultQueryParams: [KeyValuePair]
    
    /// The HTTP session used to perform network requests, resolved via dependency injection.
    public var urlSession: any HTTPSession {
        @Dependency(\.networkRequestSession) var networkRequestSession
        return networkRequestSession
    }
    
    /// Creates a new `RequestConfig` instance with optional default headers and query parameters.
    ///
    /// - Parameters:
    ///   - defaultHeaders: Headers to be included by default (optional).
    ///   - defaultQueryParams: Query parameters to be included by default (optional).
    public init(
        defaultHeaders: [KeyValuePair] = [],
        defaultQueryParams: [KeyValuePair] = []
    ) {
        self.defaultHeaders = defaultHeaders
        self.defaultQueryParams = defaultQueryParams
    }
}


@_documentation(visibility: internal)
public var requestConfig: RequestConfig {
    @Dependency(\.requestConfig) var config
    
    return config
}

extension DependencyValues {
    /// The default network request configuration used throughout the library.
    ///
    /// This property provides access to the current `RequestConfig` instance,
    /// which defines default headers, query parameters, and the URL session used for requests.
    ///
    /// The library’s default configuration is:
    /// ```swift
    /// RequestConfig(defaultHeaders: [.contentTypeJson])
    /// ```
    ///
    /// You can override this property to customize default headers, query parameters,
    /// or other networking settings. The overridden configuration will be applied to every
    /// network request performed by the library.
    ///
    /// **Important:** It is recommended to override this dependency as early as possible
    /// in your app’s lifecycle (e.g., at app startup) to ensure consistent behavior.
    ///
    /// ## Example — Overriding Default Configuration
    ///
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     init() {
    ///         prepareDependencies {
    ///             $0.requestConfig = RequestConfig(
    ///                 defaultHeaders: [KeyValuePair(key: "Authorization", value: "Bearer token123")],
    ///                 defaultQueryParams: [KeyValuePair(key: "locale", value: "en-US")]
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    public var requestConfig: RequestConfig {
        get { self[RequestConfigKey.self] }
        set { self[RequestConfigKey.self] = newValue }
    }
}


// MARK: - Overridable default request config

private enum RequestConfigKey: DependencyKey {
    static let liveValue: RequestConfig = .init(defaultHeaders: [.contentTypeJson])
    
#if DEBUG
    static let testValue: RequestConfig = .init()
#endif
}
