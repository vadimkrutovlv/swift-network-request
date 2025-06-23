/// A Swift macro that generates network request methods for creating new resources via POST requests.
///
/// The `Post` macro is an attached macro that automatically generates a `post()` instance method for creating new resources on HTTP endpoints. It simplifies the process of sending POST requests by handling URL construction, headers, query parameters, and JSON serialization declaratively.
///
/// ## Usage
///
/// Apply the `@Post` macro to a type that represents the data structure you want to create:
///
/// ```swift
/// @Post(url: "https://api.example.com/users")
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
/// @Post(url: "https://api.example.com/posts")
/// struct Post {
///     @ExcludeFromRequest let id: Int
///     var userId: Int
///     var title: String
///     var body: String
/// }
///
/// extension Post {
///     static let draft = Self(id: 0, userId: 0, title: "", body: "")
/// }
///
/// // Usage of the generated instance method
/// var post = Post.draft
/// post.body = "Test body"
/// post.title = "Test title"
/// post.userId = 123
///
/// try await post.post()
/// ```
///
/// ### With Headers
///
/// ```swift
/// @Post(
///     url: "https://api.example.com/articles",
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
/// @Post(
///     url: "https://api.example.com/comments",
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
/// @Post(url: "https://api.example.com/posts/:postId/comments")
/// struct Comment {
///     @ExcludeFromRequest let id: Int
///     let postId: Int
///     var content: String
///     var authorName: String
/// }
///
/// extension Comment {
///     static let draft = Self(id: 0, postId: 0, content: "", authorName: "")
/// }
/// // Usage - no need to pass path parameters explicitly
/// // The macro uses the instance's postId property
/// var comment = Comment.draft
/// comment.content = "great article"
/// comment.authorName = "author@article.com"
///
/// try await comment.post()
/// ```
///
/// ### Complete Example
///
/// ```swift
/// @Post(
///     url: "https://api.example.com/users/:userId/posts",
///     headers: [
///         KeyValuePair(key: "Authorization", value: "Bearer your-token"),
///         KeyValuePair(key: "Content-Type", value: "application/json")
///     ],
///     queryParams: [
///         KeyValuePair(key: "draft", value: "false"),
///         KeyValuePair(key: "notify_followers", value: "true")
///     ]
/// )
/// struct BlogPost {
///     @ExcludeFromRequest let id: Int
///     var title: String
///     @ExcludeFromRequest var userId: Int
///     var content: String
///     var tags: [String]
/// }
///
/// extension BlogPost {
///     static let draft = Self(id: 0, userId: 0, title: "", content: "", tags: [])
/// }
///
/// // Usage of the generated method with path parameters
/// let user = try await User.get(id: 123)
/// var blogPost = BlogPost.draft
/// blogPost.userId = user.id
/// blogPost.title = "My New Blog Post"
/// blogPost.content = "This is the content of my blog post"
/// blogPost.tags = ["swift", "programming"]
///
/// try await blogPost.post() // No explicit path parameters needed
/// ```
///
/// ## Generated Code
///
/// The macro generates an instance method `post()` that:
/// - Parses path parameters from the URL (e.g., `:id`, `:userId`) and automatically resolves them from matching properties in the instance
/// - Constructs the complete URL by replacing path parameters with values from the instance's properties
/// - Appends query parameters to the URL
/// - Configures HTTP headers
/// - Serializes the current instance to JSON as the request body, excluding any properties marked with `@ExcludeFromRequest`
/// - Performs the POST network request
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
/// @Post(url: "https://api.example.com/users/:userId/posts/:postId")
/// struct BlogPost {
///     let userId: Int
///     let postId: Int
///     var title: String
/// }
/// ```
///
/// The macro will generate:
/// ```swift
/// func post() async throws -> BlogPost // No explicit parameters needed
/// ```
/// Under the hood, the macro uses the `userId` and `postId` values from the instance to replace the path parameters in the URL.
///
/// ## Excluding Properties from Request Body
///
/// Use the `@ExcludeFromRequest` macro to exclude specific properties from the JSON request body:
///
/// ```swift
/// @Post(url: "https://api.example.com/users")
/// struct User {
///     @ExcludeFromRequest let id: Int        // Won't be included in POST body
///     @ExcludeFromRequest let createdAt: Date // Won't be included in POST body
///     var name: String                        // Will be included in POST body
///     var email: String                       // Will be included in POST body
/// }
/// ```
///
/// This is particularly useful for:
/// - Auto-generated fields like `id`, `createdAt`, `updatedAt`
/// - Read-only properties that should not be sent to the server
///
/// ## Error Handling
///
/// The generated `post()` method can throw errors related to:
/// - Network connectivity issues
/// - Invalid URL construction
/// - HTTP response errors (400, 401, 500, etc.)
/// - JSON encoding/decoding failures
/// - Server validation errors
///
/// Ensure proper error handling when calling the generated method:
///
/// ```swift
/// do {
///     let createdUser = try await newUser.post()
///     // Process created user object
/// } catch {
///     // Handle network, encoding, or server errors
///     print("Failed to create user: \(error)")
/// }
/// ```
///
///
/// ## Related Macros
///
/// - ``Get(url:headers:queryParams:)``: For retrieving single resources
/// - ``GetCollection(url:headers:queryParams:)``: For retrieving arrays/lists
/// - ``Put(url:headers:queryParams:)``: For updating existing resources
/// - ``Delete(url:headers:queryParams:)``: For deleting resources
///
/// - Parameters:
///   - url: The base URL endpoint for the POST request. This should be a valid HTTP/HTTPS URL string.
///   - headers: An optional array of ``KeyValuePair`` objects representing HTTP headers to include with the request. Defaults to an empty array.
///   - queryParams: An optional array of ``KeyValuePair`` objects representing query parameters to append to the URL. Defaults to an empty array.
@attached(member, names: arbitrary)
public macro Post(
    url: String,
    headers: [KeyValuePair] = [],
    queryParams: [KeyValuePair] = []
) = #externalMacro(
    module: "SwiftNetworkRequestMacros",
    type: "PostMacro"
)
