//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal protocol AdyenNetworkImageProviding {
    init()
    
    func loadImage(
        from url: URL,
        completion: @escaping (UIImage?) -> Void
    )
}

internal class AdyenNetworkImageProvider: AdyenNetworkImageProviding {
    
    private enum Constants {
        internal static let minutes10: TimeInterval = 60 * 10
    }
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadRevalidatingCacheData
        return URLSession(configuration: configuration)
    }()
    
    private var dataTask: URLSessionDataTask? {
        willSet {
            dataTask?.cancel()
        }
    }
    
    internal required init() {}
    
    internal func loadImage(
        from url: URL,
        completion: @escaping (UIImage?) -> Void
    ) {
        let urlRequest = URLRequest(
            url: url,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: Constants.minutes10
        )
        
        var task: URLSessionDataTask?
        task = session.dataTask(with: urlRequest) { [weak self] data, response, _ in
            guard let self, task === self.dataTask else { return }
            
            defer { self.dataTask = nil }
            completion(image(from: response, data: data))
        }
        task?.resume()
        
        dataTask = task
    }
    
    private func image(
        from response: URLResponse?,
        data: Data?
    ) -> UIImage? {
        
        guard
            let response = response as? HTTPURLResponse,
            response.statusCode == 200,
            let data,
            let image = UIImage(data: data, scale: 1.0)
        else {
            return nil
        }
        
        return image
    }
}
