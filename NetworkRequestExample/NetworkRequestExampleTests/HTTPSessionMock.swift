import Foundation
import SwiftNetworkRequest

struct HTTPSessionMock: HTTPSession {
    enum ResponseStatus: Int {
        case success = 200
        case serverError = 500
    }
    
    let result: (@Sendable (URLRequest) throws -> (Data, ResponseStatus))
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {    
        let (data, statusCode) = try result(request)
        
        guard let response = HTTPURLResponse(
            url: .applicationDirectory,
            statusCode: statusCode.rawValue,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw NSError(domain: "Couldn't construct a valid URLResponse", code: 0)
        }
                
        return (data, response)
    }
    
    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        (.init(), .init())
    }
    
    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        (.init(fileURLWithPath: ""), .init())
    }
}
