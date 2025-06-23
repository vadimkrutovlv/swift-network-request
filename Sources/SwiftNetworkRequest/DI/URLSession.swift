import Dependencies
import Foundation

extension DependencyValues {
    /// An overridable dependency that provides the `HTTPSession` used for performing network requests.
    ///
    /// This property is part of the `swift-dependencies` system and allows consumers to inject
    /// a custom networking session (e.g., a mock session) in tests or previews.
    ///
    /// ## Example – Overriding in a Test
    ///
    /// ```swift
    /// let mockSession = MockHTTPSession()
    ///
    /// try await withDependencies {
    ///     $0.networkRequestSession = mockSession
    /// } operation: {
    ///     var post = Post.draft
    ///     post.title = "Hello"
    ///     post.body = "Testing"
    ///     post.userId = 42
    ///
    ///     try await post.post() // Uses the injected mock session
    /// }
    /// ```
    ///
    /// By default, this dependency uses `URLSession`, but you can override it whenever needed.
    public var networkRequestSession: any HTTPSession {
        get { self[URLSessionKey.self] }
        set { self[URLSessionKey.self] = newValue }
    }
}

private enum URLSessionKey: DependencyKey {
    static let liveValue: any HTTPSession = URLSession.shared
}
