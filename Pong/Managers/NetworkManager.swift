import Foundation
import Alamofire

class NetworkManager: ObservableObject {
    
    static let networkManager = NetworkManager()
    
    // MARK: BaseURL
    var baseURL = "http://localhost:8005/api/"
    
    struct EmptyBody: Encodable {}
    struct EmptyResponse: Codable {
        var success: String
    }
    struct ErrorResponse: Codable {
        var error: String
    }
    
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

    // MARK: Normal Response Network Handler
    public func request<Success: Decodable>(route: String, method: Alamofire.HTTPMethod, successType: Success.Type, completionHandler: @escaping (Success?, ErrorResponse?) -> Void) {
        request(route: route, method: method, body: EmptyBody(), successType: successType, completionHandler: completionHandler)
    }

    public func request<Request: Encodable, Success: Decodable>(route: String, method: Alamofire.HTTPMethod, body: Request, successType: Success.Type, completionHandler: @escaping (Success?, ErrorResponse?) -> Void) {
        
        var httpHeaders: HTTPHeaders = []
        
        if let token = DAKeychain.shared["token"] {
            httpHeaders = [
                "Authorization": "Token \(token)"
            ]
        }
        
        if(method == .get) {
            AF.request(self.baseURL+route, method: method, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                        }
                    }
                }
                .responseDecodable(of: successType, decoder: decoder) { (response) in
                    guard let success = response.value else {
                        return
                    }
                    completionHandler(success, nil)
                }
                .responseDecodable(of: ErrorResponse.self, decoder: decoder) { (response) in
                    guard let error = response.value else {
                        print("NETWORK_ERROR: NetworkManager.responseDecodable \(response)")
                        return
                    }
                    completionHandler(nil, error)
                }
//                .responseData() { (response) in
//                    switch response.result {
//                    case .success:
//                        print("NETWORK: NetworkManager.responseData.success \(response)")
//                        break
//                    case let .failure(error):
//                        print("NETWORK: NetworkManager.responseData.failure \(error)")
//                    }
//                }
        } else {
            AF.request(self.baseURL+route, method: method, parameters: body, encoder: parameterEncoder, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                        } else if httpStatusCode == 204 {
                            print("NETWORK: 204 Empty")
                        }
                    }
                }
                .responseDecodable(of: successType, decoder: decoder) { (response) in
                    print("NETWORK_SUCCESS: NetworkManager.responseDecodable \(response)")
                    guard let success = response.value else { return }
                    completionHandler(success, nil)
                }
                .responseDecodable(of: ErrorResponse.self, decoder: decoder) { (response) in
                    print("NETWORK_ERROR: NetworkManager.responseDecodable \(response)")
                    guard let error = response.value else { return }
                    completionHandler(nil, error)
                }
//                .responseData() { (response) in
//                    switch response.result {
//                    case .success:
//                        print("NETWORK: NetworkManager.responseData.success \(response)")
//                        break
//                    case let .failure(error):
//                        print("NETWORK: NetworkManager.responseData.failure \(error)")
//                    }
//                }
        }
    }
    // MARK: Empty Response Network Handler
    // EmptyResponse type is arbitrary. Just needs some datatype to indicate completion was successful and return non-nil data
    public func emptyRequest(route: String, method: Alamofire.HTTPMethod, completionHandler: @escaping (EmptyResponse?, ErrorResponse?) -> Void) {
        emptyRequest(route: route, method: method, body: EmptyBody(), completionHandler: completionHandler)
    }

    public func emptyRequest<Request: Encodable>(route: String, method: Alamofire.HTTPMethod, body: Request, completionHandler: @escaping (EmptyResponse?, ErrorResponse?) -> Void) {
        
        var httpHeaders: HTTPHeaders = []
        
        if let token = DAKeychain.shared["token"] {
            httpHeaders = [
                "Authorization": "Token \(token)"
            ]
        }
        
        if(method == .get) {
            AF.request(self.baseURL+route, method: method, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                        } else if httpStatusCode == 204 {
                            print("NETWORK: 204 Empty")
                            completionHandler(EmptyResponse(success: "204"), nil)
                        }
                    }
                }
                .responseDecodable(of: ErrorResponse.self, decoder: decoder) { (response) in
                    print("NETWORK: NetworkManager.responseDecodable \(response)")
                    guard let error = response.value else { return }
                    completionHandler(nil, error)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        print("NETWORK: NetworkManager.responseData.success \(response)")
                        break
                    case let .failure(error):
                        print("NETWORK: NetworkManager.responseData.failure \(error)")
                    }
                }
        } else {
            AF.request(self.baseURL+route, method: method, parameters: body, encoder: parameterEncoder, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                        } else if httpStatusCode == 204 {
                            print("NETWORK: 204 Empty")
                            completionHandler(EmptyResponse(success: "204"), nil)
                        }
                    }
                }
                .responseDecodable(of: ErrorResponse.self, decoder: decoder) { (response) in
                    print("NETWORK: NetworkManager.responseDecodable \(response)")
                    guard let error = response.value else { return }
                    completionHandler(nil, error)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        print("NETWORK: NetworkManager.responseData.success \(response)")
                        break
                    case let .failure(error):
                        print("NETWORK: NetworkManager.responseData.failure \(error)")
                    }
                }
        }
    }
}


