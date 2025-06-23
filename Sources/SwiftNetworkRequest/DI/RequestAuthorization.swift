
import Dependencies

@_documentation(visibility: internal)
public struct RequestAuthorization: Sendable {
    public var getAuthorizationHeader: (@Sendable () async throws -> KeyValuePair)?
}

extension RequestAuthorization: DependencyKey {
    @_documentation(visibility: internal)
    public static let liveValue: Self = .init()
    
    #if DEBUG
    @_documentation(visibility: internal)
    public static let testValue: Self = .init { .init(key: "Bearer", value: "Test Token") }
    #endif
}

extension DependencyValues {
    /// The default authorization header to be included in network requests.
    ///
    /// This property asynchronously retrieves the default `KeyValuePair` representing
    /// an authorization header (e.g., `"Authorization": "Bearer <token>"`).
    ///
    /// It is intended primarily for use in authorizing requests made by the network layer.
    /// While it is technically possible to use it for other types of headers, doing so is
    /// not recommended in order to maintain clarity and consistency in header management.
    ///
    /// - Returns: A `KeyValuePair` representing the default authorization header, or `nil` if none is configured.
    /// - Throws: An error if the header retrieval fails.
    public var defaultAuthorization: RequestAuthorization {
        get { self[RequestAuthorization.self] }
        set { self[RequestAuthorization.self] = newValue }
    }
}

@_documentation(visibility: internal)
public var defaultAuthorization: KeyValuePair? {
    get async throws {
        @Dependency(\.defaultAuthorization) var defaultAuthorization
        
        return try await defaultAuthorization.getAuthorizationHeader?()
    }
}
