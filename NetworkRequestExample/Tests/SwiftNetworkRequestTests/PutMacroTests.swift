import MacroTesting
import SwiftNetworkRequestMacros
import Testing

import Testing

@Suite(.macros([PutMacro.self], record: .missing))
struct PutMacroTests {
    @Test
    func putMacroWithExcludedPropertiesAndDifferentRequestBodyKeys() async throws {
        assertMacro {
            """
            @Put(url: "https://jsonplaceholder.typicode.com/users")
            struct User {
                @ExcludeFromRequest let id: String                
                @RequestBodyKey("name_value") var name: String
                let age: Int
            }
            """
        } expansion: {
            """
            struct User {
                @ExcludeFromRequest let id: String                
                @RequestBodyKey("name_value") var name: String
                let age: Int

                struct UserPutRequestBody: Codable {
                    let name: String
                    let age: Int

                    enum CodingKeys: String, CodingKey {
                    case name = "name_value"
                    case age
                    }

                }

                func put(requestConfig: RequestConfig = .default) async throws {
                    let requestBody: UserPutRequestBody = .init(name: name, age: age)
                    let headers: [KeyValuePair] = [] + requestConfig.defaultHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams
                    let request = ApiRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "put",
                        headers: headers,
                        queryParams: queryParams,
                        body: try JSONEncoder().encode(requestBody)
                    )

                    try await requestConfig.urlSession.executeRequest(apiRequest: request)
                }
            }
            """
        }
    }

    @Test
    func putMacroWithPublicAccessLevel() {
        assertMacro {
            """
            @Put(url: "https://jsonplaceholder.typicode.com/users")
            public struct User {
                @ExcludeFromRequest let id: String                
                @RequestBodyKey("name_value") var name: String
                let age: Int
            }
            """
        } expansion: {
            """
            public struct User {
                @ExcludeFromRequest let id: String                
                @RequestBodyKey("name_value") var name: String
                let age: Int

                struct UserPutRequestBody: Codable {
                    let name: String
                    let age: Int

                    enum CodingKeys: String, CodingKey {
                    case name = "name_value"
                    case age
                    }

                }

                public func put(requestConfig: RequestConfig = .default) async throws {
                    let requestBody: UserPutRequestBody = .init(name: name, age: age)
                    let headers: [KeyValuePair] = [] + requestConfig.defaultHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams
                    let request = ApiRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "put",
                        headers: headers,
                        queryParams: queryParams,
                        body: try JSONEncoder().encode(requestBody)
                    )

                    try await requestConfig.urlSession.executeRequest(apiRequest: request)
                }
            }
            """
        }
    }
}
