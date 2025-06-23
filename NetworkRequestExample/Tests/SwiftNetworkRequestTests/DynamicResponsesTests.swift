//

import Foundation
import SwiftNetworkRequest
import Testing

@Suite(.serialized)
struct DynamicResponsesTests {
    @Test(arguments: ["data", "response", "responseBody"])
    func dynamicResponses(customPayloadKey: String) async throws {
        let response = #"""
           { 
                "\#(customPayloadKey)": {
                    "id": 1,
                    "name": "Bob",
                    "age": 25
                }
            }
        """#
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLSessionMock.self]
        
        let mockSession = URLSession(configuration: config)
        URLSessionMock.mockData = response.data(using: .utf8)
        URLSessionMock.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/users/1")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let user = try await User.get(id: "1", requestConfig: .default.withCustom(urlSession: mockSession))
        #expect(user == User(id: 1, name: "Bob", age: 25))
    }
}

@Get(url: "https://api.example.com/users/:id")
private struct User: Equatable {
    let id: Int
    var name: String
    var age: Int
}
