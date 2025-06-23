import Dependencies
import Foundation
@testable import NetworkRequestExample
import SwiftNetworkRequest
import Testing

struct PostTests {
    @Test
    mutating func getCollectionWithOverriddenDefaultRequestConfig() async throws {
        let expectedResults: [Post] = [
            .init(id: 1, userId: 1, title: "Test 1", body: "Test 1"),
            .init(id: 2, userId: 2, title: "Test 2", body: "Test 2")
        ]
        let session = HTTPSessionMock { request in
            let containsCustomHeaders = request.allHTTPHeaderFields?.contains {
                $0.key == "myHeader" && $0.value == "myValue"
            }
                                    
            #expect(request.httpMethod == "GET")
            #expect(containsCustomHeaders != nil)
            #expect(request.url?.absoluteString == "https://jsonplaceholder.typicode.com/posts?myQueryParam=testValue&myAnotherParam=anotherTestValue")
            return try (expectedResults.toData, .success)
        }
        
        try await withDependencies {
            $0.networkRequestSession = session
            $0.requestConfig = .init(
                defaultHeaders: [.init(key: "myHeader", value: "myValue")],
                defaultQueryParams: [
                    .init(key: "myQueryParam", value: "testValue"),
                    .init(key: "myAnotherParam", value: "anotherTestValue"),
                ]
            )
        } operation: {
            let result = try await Post.get()
            
            #expect(result == expectedResults)
        }
    }
    
    @Test
    mutating func get() async throws {
        let expectedResult = Post(id: 12, userId: 12345, title: "Alarm", body: "test alarm")
        let session = HTTPSessionMock { request in
            #expect(request.url?.absoluteString == "https://jsonplaceholder.typicode.com/posts/12")
            return try (expectedResult.toData, .success)
        }
        
        try await withDependencies {
            $0.networkRequestSession = session
        } operation: {
            let result = try await Post.get(id: "12")
            
            #expect(result == expectedResult)
        }

    }
    
    @Test
    mutating func post() async throws {
        let session = HTTPSessionMock { request in
            guard let httpBody = request.httpBody else {
                Issue.record("Request expected to have a body, but got nil.")
                return (.init(), .serverError)
            }
            
            let requestBody = try JSONDecoder().decode(Post.PostRequestBody.self, from: httpBody)
            #expect(request.url?.absoluteString == "https://jsonplaceholder.typicode.com/posts")
            #expect(request.httpMethod == "POST")
            #expect(requestBody == Post.PostRequestBody(userId: 123, title: "Test title", body: "Test body"))
            
            return (.init(), .success)
        }
        
        try await withDependencies {
            $0.networkRequestSession = session
        } operation: {
            var post = Post.draft
            post.body = "Test body"
            post.title = "Test title"
            post.userId = 123
                    
            try await post.post()
        }
    }
    
    @Test
    mutating func put() async throws {
        let session = HTTPSessionMock { request in
            if request.httpMethod == "PUT" {
                guard let httpBody = request.httpBody else {
                    Issue.record("Request expected to have a body, but got nil.")
                    return (.init(), .serverError)
                }
                
                let requestBody = try JSONDecoder().decode(Post.PutRequestBody.self, from: httpBody)
                let expectedRequestBody = Post.PutRequestBody(
                    userId: 12345,
                    title: "Alarm",
                    body: "Updated test alarm"
                )
                
                #expect(request.url?.absoluteString == "https://jsonplaceholder.typicode.com/posts/12")
                #expect(requestBody == expectedRequestBody)
                
                return (.init(), .success)
            } else {
                let existingPost = Post(id: 12, userId: 12345, title: "Alarm", body: "test alarm")
                return try (existingPost.toData, .success)
            }
        }
        
        try await withDependencies {
            $0.networkRequestSession = session
        } operation: {
            var updatedPost = try await Post.get(id: "12")
            updatedPost.body = "Updated test alarm"
            
            try await updatedPost.put()
        }
    }
    
    @Test
    mutating func delete() async throws {
        let session = HTTPSessionMock { request in
            #expect(request.url?.absoluteString == "https://jsonplaceholder.typicode.com/posts/12")
            #expect(request.httpMethod == "DELETE")
            return (.init(), .success)
        }
        try await withDependencies {
            $0.networkRequestSession = session
        } operation: {
            let post = Post(id: 12, userId: 1234, title: "Test", body: "test body")
            try await post.delete()
        }
    }
}

// MARK: - Testing helpers

private extension Array where Element: Encodable {
    var toData: Data {
        get throws { try JSONEncoder().encode(self) }
    }
}

private extension Encodable {
    var toData: Data {
        get throws { try JSONEncoder().encode(self) }
    }
}
