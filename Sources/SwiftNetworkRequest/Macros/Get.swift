/// A Swift macro that generates network request methods for fetching collections of data from REST APIs.
///
/// The `GetCollection` macro is an attached macro that automatically generates a `get()` method for fetching arrays of data from HTTP endpoints. It simplifies the process of creating network requests by handling URL construction, headers, and query parameters declaratively.
///
/// ## Usage
///
/// Apply the `@GetCollection` macro to a type that represents the data structure you want to fetch:
///
/// ```swift
/// @GetCollection(url: "https://api.example.com/users")
/// struct User: Codable {
///     let id: Int
///     let name: String
///     let email: String
/// }
/// ```
///
/// ### With Headers
///
/// ```swift
/// @GetCollection(
///     url: "https://api.example.com/posts",
///     headers: [
///         KeyValuePair(key: "Authorization", value: "Bearer token123"),
///         KeyValuePair(key: "Content-Type", value: "application/json")
///     ]
/// )
/// struct Post: Codable {
///     let id: Int
///     let title: String
///     let content: String
/// }
/// ```
///
/// ### With Query Parameters
///
/// ```swift
/// @GetCollection(
///     url: "https://api.example.com/products",
///     queryParams: [
///         KeyValuePair(key: "category", value: "electronics"),
///         KeyValuePair(key: "limit", value: "10")
///     ]
/// )
/// struct Product: Codable {
///     let id: Int
///     let name: String
///     let price: Double
/// }
/// ```
///
/// ### Complete Example
///
/// ```swift
/// @GetCollection(
///     url: "https://api.example.com/articles",
///     headers: [
///         KeyValuePair(key: "Authorization", value: "Bearer your-token"),
///         KeyValuePair(key: "Accept", value: "application/json")
///     ],
///     queryParams: [
///         KeyValuePair(key: "status", value: "published"),
///         KeyValuePair(key: "sort", value: "created_at")
///     ]
/// )
/// struct Article: Codable {
///     let id: Int
///     let title: String
///     let author: String
///     let createdAt: Date
/// }
///
/// // Usage of the generated method
/// let articles = try await Article.get()
/// ```
///
/// ## Generated Code
///
/// The macro generates a static asynchronous `get()` method that:
/// - Constructs the complete URL with query parameters
/// - Configures HTTP headers
/// - Performs the network request
/// - Decodes the JSON response into an array of the specified type
/// - Handles errors appropriately
///
/// ## Error Handling
///
/// The generated `get()` method can throw errors related to:
/// - Network connectivity issues
/// - Invalid URL construction
/// - HTTP response errors
/// - JSON decoding failures
///
/// Ensure proper error handling when calling the generated method:
///
/// ```swift
/// do {
///     let users = try await User.get()
///     // Process users array
/// } catch {
///     // Handle network or decoding errors
///     print("Failed to fetch users: \(error)")
/// }
/// ```
///
/// ## Related Macros
///
/// - ``Get(url:headers:queryParams:)``: For retrieving single resources
/// - ``Post(url:headers:queryParams:)``: For creating new resources
/// - ``Put(url:headers:queryParams:)``: For updating existing resources
/// - ``Delete(url:headers:queryParams:)``: For deleting resources
///
/// - Parameters:
///   - url: The base URL endpoint for the GET request. This should be a valid HTTP/HTTPS URL string.
///   - headers: An optional array of ``KeyValuePair`` objects representing HTTP headers to include with the request. Defaults to an empty array.
///   - queryParams: An optional array of ``KeyValuePair`` objects representing query parameters to append to the URL. Defaults to an empty array.
@attached(member, names: named(get), arbitrary)
public macro GetCollection(
    url: String,
    headers: [KeyValuePair] = [],
    queryParams: [KeyValuePair] = []
) = #externalMacro(
    module: "SwiftNetworkRequestMacros",
    type: "GetCollectionMacro"
)

/// A Swift macro that generates network request methods for fetching single objects from REST APIs.
///
/// The `Get` macro is an attached macro that automatically generates a `get()` method for fetching individual data objects from HTTP endpoints. It simplifies the process of creating network requests by handling URL construction, headers, and query parameters declaratively.
///
/// ## Usage
///
/// Apply the `@Get` macro to a type that represents the data structure you want to fetch:
///
/// ```swift
/// @Get(url: "https://api.example.com/user/123")
/// struct User {
///     let id: Int
///     let name: String
///     let email: String
/// }
/// ```
///
/// ### With Headers
///
/// ```swift
/// @Get(
///     url: "https://api.example.com/profile",
///     headers: [
///         KeyValuePair(key: "Authorization", value: "Bearer token123"),
///         KeyValuePair(key: "Content-Type", value: "application/json")
///     ]
/// )
/// struct Profile {
///     let id: Int
///     let displayName: String
///     let avatar: String
/// }
/// ```
///
/// ### With Query Parameters
///
/// ```swift
/// @Get(
///     url: "https://api.example.com/product",
///     queryParams: [
///         KeyValuePair(key: "id", value: "42"),
///         KeyValuePair(key: "include", value: "details")
///     ]
/// )
/// struct Product {
///     let id: Int
///     let name: String
///     let price: Double
///     let details: ProductDetails?
/// }
/// ```
///
/// ### With Path Parameters
///
/// Path parameters (like `:slug`, `:id`, `:userId`) in the URL are automatically converted to method arguments:
///
/// ```swift
/// @Get(url: "https://api.example.com/article/:slug")
/// struct Article {
///     let id: Int
///     let title: String
///     let content: String
/// }
///
/// // Usage - the generated method will have a slug parameter
/// let article = try await Article.get(slug: "my-article-slug")
/// ```
///
/// ### Complete Example
///
/// ```swift
/// @Get(
///     url: "https://api.example.com/user/:userId/post/:postId",
///     headers: [
///         KeyValuePair(key: "Authorization", value: "Bearer your-token"),
///         KeyValuePair(key: "Accept", value: "application/json")
///     ],
///     queryParams: [
///         KeyValuePair(key: "expand", value: "author,comments")
///     ]
/// )
/// struct Post: Codable {
///     let id: Int
///     let title: String
///     let content: String
///     let author: Author?
///     let comments: [Comment]?
/// }
///
/// // Usage of the generated method with path parameters
/// let post = try await Post.get(userId: 123, postId: 456)
/// ```
///
/// ## Generated Code
///
/// The macro generates a static asynchronous `get()` method that:
/// - Parses path parameters from the URL (e.g., `:slug`, `:id`, `:userId`) and converts them to method arguments
/// - Constructs the complete URL by replacing path parameters with actual values
/// - Appends query parameters to the URL
/// - Configures HTTP headers
/// - Performs the network request
/// - Decodes the JSON response into an instance of the specified type
/// - Handles errors appropriately
///
/// ## Path Parameters
///
/// The macro will automatically extract path parameters (like `:userId`, `:postId`) from the URL
/// and convert them into function arguments of the generated method.
///
/// For example, a URL like:
/// `"https://api.example.com/user/:userId/post/:postId"`
///
/// will result in the generated method:
///
/// ```swift
/// static func get(userId: Int, postId: Int) async throws -> Post
/// ```
///
/// These parameters are required and must be passed when calling the method:
///
/// ```swift
/// let post = try await Post.get(userId: 42, postId: 1001)
/// ```
///
/// ## Error Handling
///
/// The generated `get()` method can throw errors related to:
/// - Network connectivity issues
/// - Invalid URL construction
/// - HTTP response errors (404, 500, etc.)
/// - JSON decoding failures
///
/// Ensure proper error handling when calling the generated method:
///
/// ```swift
/// do {
///     let user = try await User.get()
///     // Process user object
/// } catch {
///     // Handle network or decoding errors
///     print("Failed to fetch user: \(error)")
/// }
/// ```
///
/// ## Comparison with GetCollection
///
/// Unlike ``GetCollection(url:headers:queryParams:)`` which returns an array of objects, the `Get` macro returns a single instance of the specified type. Use this macro when fetching individual resources rather than collections.
///
/// ## Related Macros
///
/// - ``GetCollection(url:headers:queryParams:)``: For retrieving arrays/lists
/// - ``Post(url:headers:queryParams:)``: For creating new resources
/// - ``Put(url:headers:queryParams:)``: For updating existing resources
/// - ``Delete(url:headers:queryParams:)``: For deleting resources
///
/// - Parameters:
///   - url: The base URL endpoint for the GET request. This should be a valid HTTP/HTTPS URL string.
///   - headers: An optional array of ``KeyValuePair`` objects representing HTTP headers to include with the request. Defaults to an empty array.
///   - queryParams: An optional array of ``KeyValuePair`` objects representing query parameters to append to the URL. Defaults to an empty array.
@attached(member, names: named(get), arbitrary)
public macro Get(
    url: String,
    headers: [KeyValuePair] = [],
    queryParams: [KeyValuePair] = []
) = #externalMacro(
    module: "SwiftNetworkRequestMacros",
    type: "GetMacro"
)
