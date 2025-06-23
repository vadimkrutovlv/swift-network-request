import MacroTesting
import SwiftNetworkRequestMacros
import Testing

@Suite(.macros([PostMacro.self], record: .missing))
struct PostMacroTests {
    @Test
    func postMacroWithExcludedProperties() {
        assertMacro {
            """
            @Post(url: "https://jsonplaceholder.typicode.com/users")
            struct User {
                @ExcludeFromRequest let id: String
                let age: Int
                let name: String
            }
            """
        } expansion: {
            """
            struct User {
                @ExcludeFromRequest let id: String
                let age: Int
                let name: String

                struct UserPostRequestBody: Codable {
                    let age: Int
                    let name: String


                     func post(requestConfig: RequestConfig = .default) async throws {
                    let requestBody: UserPostRequestBody = self
                    let headers: [KeyValuePair] = [] + requestConfig.defaultHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams
                    let request = ApiRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "post",
                        headers: headers,
                        queryParams: queryParams,
                        body: try JSONEncoder().encode(requestBody)
                    )

                    try await requestConfig.urlSession.executeRequest(apiRequest: request)
                    }
                }

                static func new(age: Int, name: String) -> UserPostRequestBody {
                    .init(age: age, name: name)
                }
            }
            """
        }
    }

    @Test
    func postMacroPubicAccessLevel() {
        assertMacro {
            """
            @Post(url: "https://jsonplaceholder.typicode.com/users")
            public struct User {
                @ExcludeFromRequest let id: String
                let age: Int
                let name: String
            }
            """
        } expansion: {
            """
            public struct User {
                @ExcludeFromRequest let id: String
                let age: Int
                let name: String

                public struct UserPostRequestBody: Codable {
                    let age: Int
                    let name: String


                    public func post(requestConfig: RequestConfig = .default) async throws {
                    let requestBody: UserPostRequestBody = self
                    let headers: [KeyValuePair] = [] + requestConfig.defaultHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams
                    let request = ApiRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "post",
                        headers: headers,
                        queryParams: queryParams,
                        body: try JSONEncoder().encode(requestBody)
                    )

                    try await requestConfig.urlSession.executeRequest(apiRequest: request)
                    }
                }

                public static func new(age: Int, name: String) -> UserPostRequestBody {
                    .init(age: age, name: name)
                }
            }
            """
        }
    }
}
