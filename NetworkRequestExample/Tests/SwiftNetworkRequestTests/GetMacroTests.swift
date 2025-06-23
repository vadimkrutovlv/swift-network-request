import MacroTesting
import SwiftNetworkRequestMacros
import Testing

@Suite(
    .macros([GetMacro.self, GetCollectionMacro.self], record: .missing)
)
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
            
                static func get(requestConfig: RequestConfig = .default) async throws -> Self {
                    let headers: [KeyValuePair] = [] + requestConfig.defaultHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams
                    let request = ApiRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "GET",
                        headers: headers,
                        queryParams: queryParams
                    )
                    let response: GetResponse = try await requestConfig.urlSession.executeRequest(apiRequest: request)
            
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
            
                static func get(category: String, requestConfig: RequestConfig = .default) async throws -> [Self] {
                    let headers: [KeyValuePair] = [] + requestConfig.defaultHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams
                    let request = ApiRequest(
                        path: "https://jsonplaceholder.typicode.com/users/\(category)",
                        httpMethod: "GET",
                        headers: headers,
                        queryParams: queryParams
                    )
                    let response: [GetCollectionResponse] = try await requestConfig.urlSession.executeRequest(apiRequest: request)
            
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

                public static func get(requestConfig: RequestConfig = .default) async throws -> Self {
                    let headers: [KeyValuePair] = [] + requestConfig.defaultHeaders
                    let queryParams: [KeyValuePair] = [] + requestConfig.defaultQueryParams
                    let request = ApiRequest(
                        path: "https://jsonplaceholder.typicode.com/users",
                        httpMethod: "GET",
                        headers: headers,
                        queryParams: queryParams
                    )
                    let response: GetResponse = try await requestConfig.urlSession.executeRequest(apiRequest: request)

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
