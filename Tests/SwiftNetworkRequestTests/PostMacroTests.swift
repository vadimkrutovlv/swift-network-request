import MacroTesting
import SwiftNetworkRequestMacros
import Testing

@Suite(.macros([PostMacro.self], record: .failed))
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

                struct PostRequestBody: Codable, Equatable {
                    let age: Int
                    let name: String


                }

                func post(
                    dynamicHeaders: [KeyValuePair] = [],
                    dynamicQueryParams: [KeyValuePair] = []
                ) async throws {
                    let requestBody: PostRequestBody = .init(age: self.age, name: self.name)
                    var headers: [KeyValuePair] = [] + requestConfig.defaultHeaders + dynamicHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams + dynamicQueryParams

                    if let defaultAuthorization = try await defaultAuthorization {
                        headers.append(defaultAuthorization)
                    }

                    try await requestConfig.urlSession.executeRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "post",
                        headers: headers,
                        queryParams: queryParams,
                        body: try JSONEncoder().encode(requestBody)
                    )
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

                struct PostRequestBody: Codable, Equatable {
                    let age: Int
                    let name: String


                }

                public func post(
                    dynamicHeaders: [KeyValuePair] = [],
                    dynamicQueryParams: [KeyValuePair] = []
                ) async throws {
                    let requestBody: PostRequestBody = .init(age: self.age, name: self.name)
                    var headers: [KeyValuePair] = [] + requestConfig.defaultHeaders + dynamicHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams + dynamicQueryParams

                    if let defaultAuthorization = try await defaultAuthorization {
                        headers.append(defaultAuthorization)
                    }

                    try await requestConfig.urlSession.executeRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "post",
                        headers: headers,
                        queryParams: queryParams,
                        body: try JSONEncoder().encode(requestBody)
                    )
                }
            }
            """
        }
    }
}
