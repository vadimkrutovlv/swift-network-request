import MacroTesting
import SwiftNetworkRequestMacros
import Testing

@Suite(
    .macros([DeleteMacro.self], record: .missing)
)
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

                func delete(id: String, requestConfig: RequestConfig = .default) async throws {
                    let headers: [KeyValuePair] = [.init(key: "content-type", value: "application/json")] + requestConfig.defaultHeaders
                    let queryParams: [KeyValuePair] = [.init(key: "user_id", value: "1")] + requestConfig.defaultQueryParams
                    let request = ApiRequest(
                        path: "https://jsonplaceholder.typicode.com/users/\(id)",
                        httpMethod: "DELETE",
                        headers: headers,
                        queryParams: queryParams
                    )

                    try await requestConfig.urlSession.executeRequest(apiRequest: request)
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

                public func delete(id: String, requestConfig: RequestConfig = .default) async throws {
                    let headers: [KeyValuePair] = [] + requestConfig.defaultHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams
                    let request = ApiRequest(
                        path: "https://jsonplaceholder.typicode.com/users/\(id)",
                        httpMethod: "DELETE",
                        headers: headers,
                        queryParams: queryParams
                    )

                    try await requestConfig.urlSession.executeRequest(apiRequest: request)
                }
            }
            """#
        }
    }
}
