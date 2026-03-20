import Foundation
@testable import MinFraudDevice

final class MockKeychainStorage: KeychainStoring, @unchecked Sendable {
    private var store: [String: String] = [:]
    var shouldFailOnSet = false

    func get(forKey key: String) -> String? {
        store[key]
    }

    func set(_ value: String, forKey key: String) -> Bool {
        if shouldFailOnSet { return false }
        store[key] = value
        return true
    }

    func reset() {
        store.removeAll()
    }
}

final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
