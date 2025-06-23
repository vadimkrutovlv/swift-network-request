//

import Dependencies
import Foundation
import SwiftNetworkRequest
import Testing

extension BaseNetworkRequest {
    struct DefaultAuthorizationTests {
        private let urlSession: URLSession
        private let response = HTTPURLResponse(
            url: URL(string: "https://api.example.com/posts/1")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        init() {
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [URLSessionMock.self]
            
            self.urlSession = URLSession(configuration: config)
            
            let response = """
                {
                    "id": 1,
                    "age": 25,
                    "name": "Bob"                    
                }
            """
            URLSessionMock.mockData = response.data(using: .utf8)
        }
                       
        @Test
        func whenDefaultAuthorizationIsNotNilReturnDefaultAuthorizationHeader() async throws {
            try await confirmation(expectedCount: 1) { confirm in
                nonisolated(unsafe) var hasAuthorizationHeader: Bool = false
                
                URLSessionMock.mockResponse = { request in
                    hasAuthorizationHeader = request.allHTTPHeaderFields?["Authorization"] == "Bearer token"
                    
                    return response
                }
                            
                try await withDependencies {
                    $0.defaultAuthorization.getAuthorizationHeader = {
                        confirm()
                        return .init(key: "Authorization", value: "Bearer token")
                    }
                    $0.networkRequestSession = urlSession
                } operation: {
                    _ = try await BlogPost.get()
                }
                
                #expect(hasAuthorizationHeader)
            }
        }
        
        @Test
        func whenDefaultAuthorizationIsNilAuthorizationHeaderIsNotAddedToRequest() async throws {            
            URLSessionMock.mockResponse = { request in
                #expect(request.allHTTPHeaderFields?["Authorization"] == nil)
                
                return response
            }
            
            try await withDependencies {
                $0.networkRequestSession = urlSession
            } operation: {
                _ = try await BlogPost.get()
            }
        }
    }
}

@Get(url: "https://api.example.com/posts/1")
private struct BlogPost {
    @ExcludeFromRequest let id: Int
    let age: Int
    let name: String
}
