import MacroTesting
import SwiftNetworkRequestMacros
import Testing

@Suite(.macros([DeleteMacro.self], record: .failed))
struct DeleteMacroTests {
    @Test
    func deleteMacroWithArguments() {
        assertMacro {
              """
            @Delete(
                url: "https://jsonplaceholder.typicode.com/users/:id",
                headers: [.init(key: "content-type", value: "application/json")],
                queryParams: [.init(key: "user_id", value: "1")]
            )
            struct User {
                let id: String
                let age: Int
                let name: String
            }
            """
        } expansion: {
            #"""
            struct User {
                let id: String
                let age: Int
                let name: String

                func delete(
                    dynamicHeaders: [KeyValuePair] = [],
                    dynamicQueryParams: [KeyValuePair] = []
                ) async throws {
                    var headers: [KeyValuePair] = [.init(key: "content-type", value: "application/json")] + requestConfig.defaultHeaders + dynamicHeaders
                    let queryParams: [KeyValuePair] = [.init(key: "user_id", value: "1")] + requestConfig.defaultQueryParams + dynamicQueryParams

                    if let defaultAuthorization = try await defaultAuthorization {
                        headers.append(defaultAuthorization)
                    }

                    try await requestConfig.urlSession.executeRequest(
                        path: "https://jsonplaceholder.typicode.com/users/\(id)",
                        httpMethod: "DELETE",
                        headers: headers,
                        queryParams: queryParams,
                        body: nil
                    )
                }
            }
            """#
        }
    }

    @Test
    func deleteMacroPublicAccessLevel() {
        assertMacro {
              """
            @Delete(url: "https://jsonplaceholder.typicode.com/users/:id")
            public struct User {
                let id: String
                let age: Int
                let name: String
            }
            """
        } expansion: {
            #"""
            public struct User {
                let id: String
                let age: Int
                let name: String

                public func delete(
                    dynamicHeaders: [KeyValuePair] = [],
                    dynamicQueryParams: [KeyValuePair] = []
                ) async throws {
                    var headers: [KeyValuePair] = [] + requestConfig.defaultHeaders + dynamicHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams + dynamicQueryParams

                    if let defaultAuthorization = try await defaultAuthorization {
                        headers.append(defaultAuthorization)
                    }

                    try await requestConfig.urlSession.executeRequest(
                        path: "https://jsonplaceholder.typicode.com/users/\(id)",
                        httpMethod: "DELETE",
                        headers: headers,
                        queryParams: queryParams,
                        body: nil
                    )
                }
            }
            """#
        }
    }
}
