/// A Swift macro that generates network request methods for deleting resources via HTTP DELETE requests.
///
/// The `Delete` macro is an attached macro that automatically generates a `delete()` instance method for removing existing resources from a RESTful HTTP API. It provides a declarative, type-safe approach for constructing DELETE requests, handling everything from path and query parameters to headers.
///
/// ## Usage
///
/// Apply the `@Delete` macro to a type that represents the resource you want to delete:
///
/// ```swift
/// @Delete(url: "https://api.example.com/users/:id")
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
/// @Delete(url: "https://api.example.com/posts/:id")
/// struct Post {
///     let id: Int
///     var title: String
///     var content: String
/// }
///
/// let post = try await Post.get(id: 42)
/// try await post.delete() // Automatically uses `id` to fill `:id` in URL
/// ```
///
/// ### With Headers
///
/// ```swift
/// @Delete(
///     url: "https://api.example.com/articles/:id",
///     headers: [
///         KeyValuePair(key: "Authorization", value: "Bearer token123")
///     ]
/// )
/// struct Article {
///     let id: Int
///     var title: String
/// }
///
/// let article = try await Article.get(id: 99)
/// try await article.delete() // Automatically uses `id` to fill `:id` in URL
/// ```
///
/// ### With Query Parameters
///
/// ```swift
/// @Delete(
///     url: "https://api.example.com/comments/:id",
///     queryParams: [
///         KeyValuePair(key: "force", value: "true")
///     ]
/// )
/// struct Comment {
///     let id: Int
///     var text: String
/// }
///
/// let comment = try await Comment.get(id: 501)
/// try await comment.delete() // Appends `?force=true` to the URL and automatically uses `id` to fill `:id` in URL
/// ```
///
/// ### With Path Parameters
///
/// Path parameters like `:userId` or `:commentId` in the URL are automatically replaced with values from matching instance properties:
///
/// ```swift
/// @Delete(url: "https://api.example.com/users/:userId/comments/:commentId")
/// struct Comment {
///     let userId: Int    // Matches `:userId`
///     let commentId: Int // Matches `:commentId`
///     var content: String
/// }
///
/// let comment = try await Comment.get(userId: 10, commentId: 99)
/// try await comment.delete()
/// ```
///
/// ### Complete Example
///
/// ```swift
/// @Delete(
///     url: "https://api.example.com/teams/:teamId/members/:memberId",
///     headers: [
///         KeyValuePair(key: "Authorization", value: "Bearer your-token")
///     ],
///     queryParams: [
///         KeyValuePair(key: "revoke_access", value: "true")
///     ]
/// )
/// struct TeamMember {
///     let teamId: Int
///     let memberId: Int
///     var name: String
/// }
///
/// let member = try await TeamMember.get(teamId: 1, memberId: 24)
/// try await member.delete()
/// ```
///
/// ## Generated Code
///
/// The macro generates an instance method `delete()` that:
/// - Parses and replaces path parameters in the URL from the instance’s properties
/// - Appends query parameters to the URL
/// - Adds any custom headers
/// - Performs the DELETE network request
/// - Throws meaningful errors on failure
///
/// **Important**: Path parameters in the URL (e.g., `:userId`, `:postId`) must match the property names in your model.
/// The macro automatically uses these property values to construct the final request URL—no explicit arguments are needed.
///
/// For example, given the URL:
/// `"https://api.example.com/users/:userId/posts/:postId"`
///
/// and the following model:
/// ```swift
/// @Delete(url: "https://api.example.com/users/:userId/posts/:postId")
/// struct BlogPost {
///     let userId: Int
///     let postId: Int
///     var title: String
/// }
/// ```
///
/// The macro will generate:
/// ```swift
/// func delete() async throws -> BlogPost // No explicit parameters needed
/// ```
/// Under the hood, the macro uses the `userId` and `postId` values from the instance to replace the path parameters in the URL.
///
/// ## Error Handling
///
/// The generated `delete()` method can throw errors such as:
/// - URL formatting issues
/// - Network errors (timeouts, offline, etc.)
/// - Server errors (403, 404, 500)
/// - JSON decoding issues (if a response is expected)
///
/// Always handle errors using `do/catch`:
///
/// ```swift
/// do {
///     try await someModel.delete()
///     print("Deleted successfully")
/// } catch {
///     print("Failed to delete resource: \(error)")
/// }
/// ```
///
/// - Parameters:
///   - url: The endpoint URL string for the DELETE request. May include `:param` placeholders that map to instance properties.
///   - headers: Optional HTTP headers to include with the request.
///   - queryParams: Optional query parameters to append to the request URL.

@attached(member, names: arbitrary)
public macro Delete(
    url: String,
    headers: [KeyValuePair] = [],
    queryParams: [KeyValuePair] = []
) = #externalMacro(
    module: "SwiftNetworkRequestMacros",
    type: "DeleteMacro"
)
