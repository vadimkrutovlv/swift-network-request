import Foundation

/// A protocol abstraction for performing HTTP network operations, designed for testability and dependency injection.
///
/// The `HTTPSession` protocol defines an interface for performing HTTP requests using Swift's async/await concurrency model. It mirrors core methods of `URLSession`—`data`, `upload`, and `download`—while making them easier to override in tests or alternative environments.
///
/// This library **depends on the [swift-dependencies](https://github.com/pointfreeco/swift-dependencies)** framework and provides a built-in conformance of `URLSession` to this protocol. This means consumers don't need to manually conform `URLSession` themselves—the only thing required is to override the dependency when needed (e.g., in unit tests or previews).
///
/// ## Purpose
///
/// `HTTPSession` is used to:
/// - Abstract away the use of `URLSession`
/// - Support mocking and stubbing in tests
/// - Enable injection of custom networking behavior
///
/// ## Testing Example
///
/// Here's how to override the default `networkRequestSession` dependency in a test using `swift-dependencies`:
///
/// ```swift
/// let session = MockHTTPSession()
///
/// try await withDependencies {
///     $0.networkRequestSession = session
/// } operation: {
///     var post = Post.draft
///     post.body = "Test body"
///     post.title = "Test title"
///     post.userId = 123
///
///     try await post.post() // Uses the injected mock session
/// }
/// ```
///
/// ## Methods
///
/// - `data(for:)`: Performs a standard HTTP request and returns the data and response.
/// - `upload(for:from:)`: Sends HTTP body data (typically for `POST` or `PUT`) and returns the result.
/// - `download(for:)`: Downloads a file and returns its temporary URL and response.
///
/// ## Notes
///
/// - `URLSession` already conforms to this protocol and is used by default.
/// - Only override `networkRequestSession` when mocking or customizing behavior in different environments (e.g., testing or previews).
///
/// ## See Also
///
/// - [`swift-dependencies`](https://github.com/pointfreeco/swift-dependencies)
public protocol HTTPSession: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse)
    func download(for request: URLRequest) async throws -> (URL, URLResponse)
}

struct ApiRequest: Sendable {
    let path: String
    let httpMethod: String
    let headers: [KeyValuePair]
    let queryParams: [KeyValuePair]
    let body: Data?
    
    init(
        path: String,
        httpMethod: String,
        headers: [KeyValuePair],
        queryParams: [KeyValuePair],
        body: Data? = nil
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.headers = headers
        self.queryParams = queryParams
        self.body = body
    }
}

struct ApiRequestError: Error {
    public let message: String
}

extension URLSession: HTTPSession {
    public func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        try await self.download(for: request, delegate: nil)
    }
}

extension HTTPSession {
    public func executeRequest<T: Codable>(
        path: String,
        httpMethod: String,
        headers: [KeyValuePair],
        queryParams: [KeyValuePair],
        body: Data? = nil
    ) async throws -> T {
        let data = try await executeRequest(
            path: path,
            httpMethod: httpMethod,
            headers: headers,
            queryParams: queryParams,
            body: body
        )

        return try JSONDecoder().decode(DynamicAPIResponse<T>.self, from: data).data
    }

    @discardableResult
    public func executeRequest(
        path: String,
        httpMethod: String,
        headers: [KeyValuePair],
        queryParams: [KeyValuePair],
        body: Data?
    ) async throws -> Data {
        let urlRequest = try createURLRequest(
            apiRequest: .init(
                path: path,
                httpMethod: httpMethod,
                headers: headers,
                queryParams: queryParams,
                body: body
            )
        )
        let (data, response) = try await self.data(for: urlRequest)
        try handleResponse(data: data, response: response)

        return data
    }

    func createURLRequest(apiRequest: ApiRequest) throws -> URLRequest {
        var components = URLComponents(string: apiRequest.path)
        
        if !apiRequest.queryParams.isEmpty {
            components?.queryItems = apiRequest.queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = components?.url else {
            throw ApiRequestError(message: "Invalid Url.")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = apiRequest.httpMethod
        
        for header in apiRequest.headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }

        if let body = apiRequest.body {
            request.httpBody = body
        }
        
        return request
    }
    
    func handleResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiRequestError(message: "Invalid Response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
