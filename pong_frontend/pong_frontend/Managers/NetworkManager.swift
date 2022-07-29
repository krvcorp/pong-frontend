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
    
    public func request<Success: Decodable>(route: String, method: Alamofire.HTTPMethod, successType: Success.Type, completionHandler: @escaping (Success) -> Void) {
        request(route: route, method: method, body: EmptyBody(), successType: successType, completionHandler: completionHandler)
    }

    public func request<Request: Encodable, Success: Decodable>(route: String, method: Alamofire.HTTPMethod, body: Request, successType: Success.Type, completionHandler: @escaping (Success) -> Void) {
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        let httpHeaders: HTTPHeaders = [
            "Authorization": "Token \(token)"
        ]
        
        if(method == .get) {
            AF.request(self.baseURL+route, method: method, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        if httpStatusCode == 401 {
//                            AuthManager.authManager.signOut()
                            print("DEBUG: authmanager signout here?")
                        }
                    }
                }
                .responseDecodable(of: successType) { (response) in
                    print("DEBUG: \(response)")
                    guard let success = response.value else { return }
                    completionHandler(success)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        debugPrint(response)
                        break
                    case let .failure(error):
                        print(error)
                        debugPrint(response)
                    }
                }
        } else {
            AF.request(self.baseURL+route, method: method, parameters: body, encoder: JSONParameterEncoder(), headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        if httpStatusCode == 401 {
//                            AuthManager.authManager.signOut()
                            print("DEBUG: auth manager sign out?")
                        }
                    }
                }
                .responseDecodable(of: successType) { (response) in
                    guard let success = response.value else { return }
                    completionHandler(success)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
//                        debugPrint(response)
                        break
                    case let .failure(error):
                        print(error)
//                        debugPrint(response)
                    }
                }
        }
    }
}


