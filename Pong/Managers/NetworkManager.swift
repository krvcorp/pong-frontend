//
//  NetworkManager.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/29/22.
//

import Foundation
import Alamofire

class NetworkManager: ObservableObject {
    
    static let networkManager = NetworkManager()
    
    var baseURL = "http://localhost:8005/api/"
    
    struct EmptyBody: Encodable {}
    
    // MARK: Encode/Decode to/from SnakeCase
    let parameterEncoder: JSONParameterEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let parameterEncoder = JSONParameterEncoder(encoder: encoder)
        return parameterEncoder
    }()
    
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    
    public func request<Success: Decodable>(route: String, method: Alamofire.HTTPMethod, successType: Success.Type, completionHandler: @escaping (Success) -> Void) {
        request(route: route, method: method, body: EmptyBody(), successType: successType, completionHandler: completionHandler)
    }

    public func request<Request: Encodable, Success: Decodable>(route: String, method: Alamofire.HTTPMethod, body: Request, successType: Success.Type, completionHandler: @escaping (Success) -> Void) {
        
        var httpHeaders: HTTPHeaders = []
        
        if let token = DAKeychain.shared["token"] {
            httpHeaders = [
                "Authorization": "Token \(token)"
            ]
        }
        
        // MARK: GET
        if(method == .get) {
            AF.request(self.baseURL+route, method: method, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        if httpStatusCode == 401 {
                            print("DEBUG: 401 Error")
                        }
                    }
                }
                .responseDecodable(of: successType, decoder: decoder) { (response) in
                    print("DEBUG: \(response)")
                    guard let success = response.value else { return }
                    completionHandler(success)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        print("DEBUG: .success \(response)")
                        break
                    case let .failure(error):
                        print("DEBUG: .failure error \(error)")
                        print("DEBUG: .failure response \(response)")
                    }
                }
        }
        // MARK: OTHERS (POST, DELETE, etc.)
        else {
            AF.request(self.baseURL+route, method: method, parameters: body, encoder: parameterEncoder, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        if httpStatusCode == 401 {
                            print("DEBUG: 401 Error")
                        }
                    }
                }
                .responseDecodable(of: successType, decoder: decoder) { (response) in
                    guard let success = response.value else { return }
                    completionHandler(success)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        print("DEBUG: .success \(response)")
                        break
                    case let .failure(error):
                        print("DEBUG: .failure error \(error)")
                        print("DEBUG: .failure response \(response)")
                    }
                }
        }
    }
}


