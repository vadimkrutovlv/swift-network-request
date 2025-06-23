//

import Foundation
import Dependencies
import SwiftNetworkRequest
import Testing

extension BaseNetworkRequest {
    struct DynamicResponsesTests {
        private let urlSession: URLSession
        
        init() {
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [URLSessionMock.self]
            
            self.urlSession = URLSession(configuration: config)
            URLSessionMock.mockResponse = { _ in
                HTTPURLResponse(
                    url: URL(string: "https://api.example.com/users/1")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )
            }
        }
        
        @Test(arguments: ["data", "response", "responseBody"])
        func dynamicResponsesWithObjectKeys(customPayloadKey: String) async throws {
            let response = #"""
           { 
                "\#(customPayloadKey)": {
                    "id": 1,
                    "name": "Bob",
                    "age": 25
                }
            }
        """#
            
            try await assertSingleValue(response: response)
        }
        
        @Test
        func singleValueResponse() async throws {
            let response = #"""
            { 
                "id": 1,
                "name": "Bob",
                "age": 25
            }
        """#
            
            try await assertSingleValue(response: response)
        }
        
        @Test
        func arrayOfValuesResponse() async throws {
            let response = #"""
            [{ 
                "id": 1,
                "name": "Bob",
                "age": 25
            }]
        """#
            
            URLSessionMock.mockData = response.data(using: .utf8)
            
            try await withDependencies {
                $0.networkRequestSession = urlSession
            } operation: {
                let users = try await User.get()
                #expect(users == [User(id: 1, name: "Bob", age: 25)])
            }
        }
    }
}


private extension BaseNetworkRequest.DynamicResponsesTests {
    func assertSingleValue(response: String) async throws {
        URLSessionMock.mockData = response.data(using: .utf8)
        
        try await withDependencies {
            $0.networkRequestSession = urlSession
        } operation: {
            let user = try await User.get(id: "1")
            #expect(user == User(id: 1, name: "Bob", age: 25))
        }
    }
}

@GetCollection(url: "https://api.example.com/users")
@Get(url: "https://api.example.com/users/:id")
private struct User: Equatable {
    let id: Int
    var name: String
    var age: Int
}
