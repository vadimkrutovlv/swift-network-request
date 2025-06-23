import Foundation

final class URLSessionMock: URLProtocol {
    nonisolated(unsafe) static var mockData: Data?
    nonisolated(unsafe) static var mockResponse: URLResponse?
    nonisolated(unsafe) static var mockError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = URLSessionMock.mockError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = URLSessionMock.mockResponse {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = URLSessionMock.mockData {
                client?.urlProtocol(self, didLoad: data)
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
