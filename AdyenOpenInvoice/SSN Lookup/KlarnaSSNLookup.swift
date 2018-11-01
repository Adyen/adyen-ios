//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

//internal class KlarnaSSNLookup {
//    
//    func perform(request: KlarnaSNNLookupRequest, completion: @escaping Completion<Result<KlarnaSSNLookupResponse>>) {
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//        urlRequest.allHTTPHeaderFields = [
//            "Accept": "application/json",
//            "Content-Type": "application/json"
//        ]
//        
//        do {
//            urlRequest.httpBody = try Coder.encode(request)
//        } catch {
//            completion(.failure(error))
//            
//            return
//        }
//        
//        urlSession.dataTask(with: urlRequest) { result in
//            switch result {
//            case let .success(data):
//                print(data.base64EncodedString())
//                do {
//                    let response = try Coder.decode(data) as KlarnaSSNLookupResponse
//                    completion(.success(response))
//                } catch {
//                    completion(.failure(error))
//                }
//            case let .failure(error):
//                print(error.localizedDescription)
//                completion(.failure(error))
//            }
//        }.resume()
//    }
//    
//    private let urlSession = URLSession.shared
//}
