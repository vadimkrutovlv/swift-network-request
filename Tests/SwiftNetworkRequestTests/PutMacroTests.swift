import MacroTesting
import SwiftNetworkRequestMacros
import Testing

import Testing

@Suite(.macros([PutMacro.self], record: .failed))
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

                struct PutRequestBody: Codable, Equatable {
                    let name: String
                    let age: Int

                    enum CodingKeys: String, CodingKey {
                    case name = "name_value"
                    case age
                    }
                }

                func put(
                    dynamicHeaders: [KeyValuePair] = [],
                    dynamicQueryParams: [KeyValuePair] = []
                ) async throws {
                    let requestBody: PutRequestBody = .init(name: self.name, age: self.age)
                    var headers: [KeyValuePair] = [] + requestConfig.defaultHeaders + dynamicHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams + dynamicQueryParams

                    if let defaultAuthorization = try await defaultAuthorization {
                        headers.append(defaultAuthorization)
                    }

                    try await requestConfig.urlSession.executeRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "put",
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

                struct PutRequestBody: Codable, Equatable {
                    let name: String
                    let age: Int

                    enum CodingKeys: String, CodingKey {
                    case name = "name_value"
                    case age
                    }
                }

                public func put(
                    dynamicHeaders: [KeyValuePair] = [],
                    dynamicQueryParams: [KeyValuePair] = []
                ) async throws {
                    let requestBody: PutRequestBody = .init(name: self.name, age: self.age)
                    var headers: [KeyValuePair] = [] + requestConfig.defaultHeaders + dynamicHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams + dynamicQueryParams

                    if let defaultAuthorization = try await defaultAuthorization {
                        headers.append(defaultAuthorization)
                    }

                    try await requestConfig.urlSession.executeRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "put",
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
