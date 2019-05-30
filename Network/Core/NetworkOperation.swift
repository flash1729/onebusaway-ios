//
//  NetworkOperation.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 1/22/19.
//  Copyright © 2019 OneBusAway. All rights reserved.
//

import Foundation

@objc(OBANetworkOperation)
public class NetworkOperation: AsyncOperation {
    public let request: URLRequest
    public private(set) var data: Data?
    public internal(set) var response: HTTPURLResponse?
    private var dataTask: URLSessionDataTask?

    public required init(request: URLRequest) {
        self.request = request
        super.init()
        self.name = request.url?.absoluteString
    }

    public override func start() {
        super.start()

        let session = URLSession.shared
        dataTask = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard
                let self = self,
                !self.isCancelled
            else {
                return
            }

            self.set(data: data, response: response as? HTTPURLResponse, error: error)

            self.finish()
        }

        dataTask?.resume()
    }

    internal func set(data: Data?, response: HTTPURLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }

    public var success: Bool {
        return response?.statusCode == 200
    }

    public override func cancel() {
        super.cancel()
        dataTask?.cancel()
        finish()
    }

    class func buildURL(fromBaseURL baseURL: URL, path: String, queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = path
        components.queryItems = queryItems

        return components.url!
    }

    class func buildRequest(for url: URL) -> URLRequest {
        return URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
    }
}
