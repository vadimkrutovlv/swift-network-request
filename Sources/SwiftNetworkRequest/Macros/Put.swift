/// A Swift macro that generates network request methods for updating existing resources via PUT requests.
///
/// The `Put` macro is an attached macro that automatically generates a `put()` instance method for updating existing resources on HTTP endpoints. It simplifies the process of sending PUT requests by handling URL construction, headers, query parameters, and JSON serialization declaratively.
///
/// ## Usage
///
/// Apply the `@Put` macro to a type that represents the data structure you want to update:
///
/// ```swift
/// @Put(url: "https://api.example.com/users/:id")
/// struct User {
///     let id: Int
///     var name: String
///     var email: String
/// }
/// ```
///
/// ### Basic Example
///
/// ```swift
/// @Put(url: "https://api.example.com/posts/:id")
/// struct Post {
///     let id: Int
///     var userId: Int
///     var title: String
///     var body: String
/// }
///
/// // Usage of the generated instance method
/// // The macro automatically uses the instance's id property for the :id path parameter
/// var post = Post.get(id: 123)
/// post.title = "Updated title"
/// try await post.put() // No need to pass id explicitly
/// ```
///
/// ### With Headers
///
/// ```swift
/// @Put(
///     url: "https://api.example.com/articles/:id",
///     headers: [
///         KeyValuePair(key: "Authorization", value: "Bearer token123"),
///         KeyValuePair(key: "Content-Type", value: "application/json")
///     ]
/// )
/// struct Article {
///     @ExcludeFromRequest let id: Int
///     var title: String
///     var content: String
///     var authorId: Int
/// }
/// ```
///
/// ### With Query Parameters
///
/// ```swift
/// @Put(
///     url: "https://api.example.com/comments/:id",
///     queryParams: [
///         KeyValuePair(key: "notify", value: "true"),
///         KeyValuePair(key: "moderate", value: "false")
///     ]
/// )
/// struct Comment {
///     @ExcludeFromRequest let id: Int
///     var postId: Int
///     var content: String
///     var authorEmail: String
/// }
/// ```
///
/// ### With Path Parameters
///
/// Path parameters (like `:id`, `:userId`) in the URL are automatically resolved from the instance's properties:
///
/// ```swift
/// @Put(url: "https://api.example.com/users/:userId/posts/:postId")
/// struct Post {
///     let postId: Int  // Matches :postId in URL
///     let userId: Int  // Matches :userId in URL
///     var title: String
///     var content: String
///     var status: String
/// }
///
/// // Usage - no need to pass path parameters explicitly
/// // The macro uses the instance's userId and postId properties
/// var post = Post.get(postId: 123)
/// post.status = "published"
/// try await post.put()
/// ```
///
/// ### Complete Example
///
/// ```swift
/// @Put(
///     url: "https://api.example.com/users/:userId/profile/:profileId",
///     headers: [
///         KeyValuePair(key: "Authorization", value: "Bearer your-token"),
///         KeyValuePair(key: "Content-Type", value: "application/json")
///     ],
///     queryParams: [
///         KeyValuePair(key: "validate", value: "true"),
///         KeyValuePair(key: "send_notification", value: "false")
///     ]
/// )
/// struct UserProfile {
///     let profileId: Int  // Matches :profileId in URL
///     let userId: Int     // Matches :userId in URL
///     @ExcludeFromRequest let createdAt: Date
///     var displayName: String
///     var bio: String
///     var avatarUrl: String
/// }
///
/// // Usage - path parameters are automatically resolved from instance properties
/// var profile = UserProfile.get(profileId: 789)
/// profile.bio = "Updated bio"
///
/// try await profile.put() // No explicit path parameters needed
/// ```
///
/// ## Generated Code
///
/// The macro generates an instance method `put()` that:
/// - Parses path parameters from the URL (e.g., `:id`, `:userId`) and automatically resolves them from matching properties in the instance
/// - Constructs the complete URL by replacing path parameters with values from the instance's properties
/// - Appends query parameters to the URL
/// - Configures HTTP headers
/// - Serializes the current instance to JSON as the request body, excluding any properties marked with `@ExcludeFromRequest`
/// - Performs the PUT network request
/// - Handles errors appropriately
///
/// **Important**: Path parameters in the URL (e.g., `:userId`, `:postId`) must match the property names in your model.
/// The macro automatically uses these property values to construct the final request URL—no explicit arguments are needed.
///
/// For example, given the URL:
/// `"https://api.example.com/users/:userId/posts/:postId"`
///
/// and the following model:
/// ```swift
/// @Put(url: "https://api.example.com/users/:userId/posts/:postId")
/// struct BlogPost {
///     let userId: Int
///     let postId: Int
///     var title: String
/// }
/// ```
///
/// The macro will generate:
/// ```swift
/// func put() async throws -> BlogPost // No explicit parameters needed
/// ```
/// Under the hood, the macro uses the `userId` and `postId` values from the instance to replace the path parameters in the URL.
///
/// ## Excluding Properties from Request Body
///
/// Use the `@ExcludeFromRequest` macro to exclude specific properties from the JSON request body:
///
/// ```swift
/// @Put(url: "https://api.example.com/users/:id")
/// struct User {
///     @ExcludeFromRequest let id: Int        // Won't be included in PUT body
///     @ExcludeFromRequest let createdAt: Date // Won't be included in PUT body
///     @ExcludeFromRequest let updatedAt: Date // Won't be included in PUT body
///     var name: String                        // Will be included in PUT body
///     var email: String                       // Will be included in PUT body
/// }
/// ```
///
/// This is particularly useful for:
/// - Auto-generated fields like `id`, `createdAt`, `updatedAt`
/// - Read-only properties that should not be sent to the server
/// - Computed properties or derived values
/// - Server-managed metadata
///
/// ## Error Handling
///
/// The generated `put()` method can throw errors related to:
/// - Network connectivity issues
/// - Invalid URL construction
/// - HTTP response errors (400, 401, 404, 500, etc.)
/// - JSON encoding/decoding failures
/// - Server validation errors
/// - Resource not found errors (404)
///
/// Ensure proper error handling when calling the generated method:
///
/// ```swift
/// do {
///     let updatedUser = try await existingUser.put() // No explicit id parameter needed
///     // Process updated user object
/// } catch {
///     // Handle network, encoding, or server errors
///     print("Failed to update user: \(error)")
/// }
/// ```
/// ## Related Macros
///
/// - ``Get(url:headers:queryParams:)``: For retrieving single resources
/// - ``GetCollection(url:headers:queryParams:)``: For retrieving arrays/lists
/// - ``Post(url:headers:queryParams:)``: For creating new resources
/// - ``Delete(url:headers:queryParams:)``: For deleting resources
///
/// - Parameters:
///   - url: The base URL endpoint for the PUT request. This should be a valid HTTP/HTTPS URL string, typically including an identifier like `:id`.
///   - headers: An optional array of ``KeyValuePair`` objects representing HTTP headers to include with the request. Defaults to an empty array.
///   - queryParams: An optional array of ``KeyValuePair`` objects representing query parameters to append to the URL. Defaults to an empty array.
@attached(member, names: arbitrary)
public macro Put(
    url: String,
    headers: [KeyValuePair] = [],
    queryParams: [KeyValuePair] = []
) = #externalMacro(
    module: "SwiftNetworkRequestMacros",
    type: "PutMacro"
)
