/// A simple key-value pair structure used to represent HTTP headers or query parameters.
///
/// This struct is designed to be `Sendable` for safe use in concurrent contexts.
/// It encapsulates a `key` and its corresponding `value`, both as strings.
///
/// ## Usage
///
/// You can use `KeyValuePair` to specify HTTP headers or query parameters in network requests.
///
/// ```swift
/// let header = KeyValuePair(key: "Authorization", value: "Bearer token123")
/// let queryParam = KeyValuePair(key: "page", value: "1")
/// ```
public struct KeyValuePair: Sendable {
    /// The key of the key-value pair.
    public let key: String
    
    /// The value corresponding to the key.
    public let value: String
    
    /// Creates a new `KeyValuePair` with the specified key and value.
    ///
    /// - Parameters:
    ///   - key: The key string.
    ///   - value: The value string.
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

///
/// The extension provides a commonly used header key-value pair for JSON content type:
///
/// ```swift
/// let jsonHeader: KeyValuePair = .contentTypeJson
/// // Equivalent to ("Content-Type": "application/json")
/// ```
public extension KeyValuePair {
    static let contentTypeJson = Self(key: "Content-Type", value: "application/json")
}
