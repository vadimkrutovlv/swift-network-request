import MacroTesting
import SwiftNetworkRequestMacros
import Testing

@Suite(.macros([GetMacro.self, GetCollectionMacro.self], record: .failed))
struct GetMacroTests {
    @Test
    func getMacro() {
        assertMacro {
            """
            @Get(url: "https://jsonplaceholder.typicode.com/users")
            struct User {
                let id: String
                let age: Int
                let name: String
            }
            """
        } expansion: {
            """
            struct User {
                let id: String
                let age: Int
                let name: String

                static func get(
                    dynamicHeaders: [KeyValuePair] = [],
                    dynamicQueryParams: [KeyValuePair] = []
                ) async throws -> Self {
                    var headers: [KeyValuePair] = [] + requestConfig.defaultHeaders + dynamicHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams + dynamicQueryParams

                    if let defaultAuthorization = try await defaultAuthorization {
                        headers.append(defaultAuthorization)
                    }

                    let response: GetResponse = try await requestConfig.urlSession.executeRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "GET",
                        headers: headers,
                        queryParams: queryParams
                    )

                    return .init(id: response.id, age: response.age, name: response.name)
                }

                struct GetResponse: Codable {
                    let id: String
                    let age: Int
                    let name: String


                }
            }
            """
        }
    }

    @Test
    func getMacroCollectionWithPathParameter() {
        assertMacro {
            """
            @GetCollection(url: "https://jsonplaceholder.typicode.com/users/:category")
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

                static func get(
                    category: String,
                    dynamicHeaders: [KeyValuePair] = [],
                    dynamicQueryParams: [KeyValuePair] = []
                ) async throws -> [Self] {
                    var headers: [KeyValuePair] = [] + requestConfig.defaultHeaders + dynamicHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams + dynamicQueryParams

                    if let defaultAuthorization = try await defaultAuthorization {
                        headers.append(defaultAuthorization)
                    }

                    let response: [GetCollectionResponse] = try await requestConfig.urlSession.executeRequest(
                        path: "https://jsonplaceholder.typicode.com/users/\(category)",
                        httpMethod: "GET",
                        headers: headers,
                        queryParams: queryParams
                    )

                    return response.map { response in
                        .init(id: response.id, age: response.age, name: response.name)
                    }
                }

                struct GetCollectionResponse: Codable {
                    let id: String
                    let age: Int
                    let name: String


                }
            }
            """#
        }
    }

    @Test
    func getMacroPublicAccessLevel() {
        assertMacro {
            """
            @Get(url: "https://jsonplaceholder.typicode.com/users")
            public struct User {
                let id: String
                let age: Int
                @RequestBodyKey("email_value") public var email: String
            }
            """
        } expansion: {
            """
            public struct User {
                let id: String
                let age: Int
                @RequestBodyKey("email_value") public var email: String

                public static func get(
                    dynamicHeaders: [KeyValuePair] = [],
                    dynamicQueryParams: [KeyValuePair] = []
                ) async throws -> Self {
                    var headers: [KeyValuePair] = [] + requestConfig.defaultHeaders + dynamicHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams + dynamicQueryParams

                    if let defaultAuthorization = try await defaultAuthorization {
                        headers.append(defaultAuthorization)
                    }

                    let response: GetResponse = try await requestConfig.urlSession.executeRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "GET",
                        headers: headers,
                        queryParams: queryParams
                    )

                    return .init(id: response.id, age: response.age, email: response.email)
                }

                struct GetResponse: Codable {
                    let id: String
                    let age: Int
                    let email: String

                    enum CodingKeys: String, CodingKey {
                    case id
                    case age
                    case email = "email_value"
                    }
                }
            }
            """
        }
    }
}
