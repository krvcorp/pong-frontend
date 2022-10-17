import Foundation
import Alamofire

class NetworkManager: ObservableObject {
    
    static let networkManager = NetworkManager()
    
    // MARK: BaseURL
    #if DEBUG
//        var baseURL = "http://localhost:8005/api/"
//        var rootURL = "http://localhost:8005/"
        var baseURL = "https://www.pong.college/api/"
        var rootURL = "https://www.pong.college/"
    #else
        var baseURL = "https://www.pong.college/api/"
        var rootURL = "https://www.pong.college/"
    #endif
    
    
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
                            AuthManager.authManager.signout()
                        }
                    }
                }
                .responseDecodable(of: successType, decoder: decoder) { (response) in
                    guard let success = response.value else {
                        return
                    }
                    print("NETWORK: \(route)")
                    print("NETWORK: .responseDecodable Success")
                    completionHandler(success, nil)
                }
                .responseDecodable(of: ErrorResponse.self, decoder: decoder) { (response) in
                    guard let error = response.value else {
                        return
                    }
                    print("NETWORK: \(route)")
                    print("NETWORK: .responseDecodable Error")
                    completionHandler(nil, error)
                }
                .responseJSON() { (response) in
                    switch response.result {
                    case .success:
                        print("NETWORK: \(route)")
                        print("NETWORK: .responseJSON Success")
                        break
                    case let .failure(error):
//                        print("NETWORK: \(route)")
//                        print("NETWORK: .responseJSON Error \(error.localizedDescription)")
                        completionHandler(nil, ErrorResponse(error: "Something went wrong!"))
                    }
                }
        } else {
            AF.request(self.baseURL+route, method: method, parameters: body, encoder: parameterEncoder, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                            AuthManager.authManager.signout()
                        } else if httpStatusCode == 204 {
//                            print("NETWORK: 204 Empty")
                        }
                    }
                }
                .responseDecodable(of: successType, decoder: decoder) { (response) in
                    guard let success = response.value else { return }
                    completionHandler(success, nil)
                }
                .responseDecodable(of: ErrorResponse.self, decoder: decoder) { (response) in
                    guard let error = response.value else { return }
                    completionHandler(nil, error)
                }
                .responseJSON() { (response) in
                    switch response.result {
                    case .success:
                        break
                    case let .failure(error):
                        print("NETWORK: \(error.localizedDescription)")
                        completionHandler(nil, ErrorResponse(error: "Something went wrong!"))
                    }
                }
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
                            AuthManager.authManager.signout()
                        } else if httpStatusCode == 204 || httpStatusCode == 200 || httpStatusCode == 201 || httpStatusCode == 405 {
                            completionHandler(EmptyResponse(success: "204"), nil)
                        }
                    }
                }
                .responseDecodable(of: ErrorResponse.self, decoder: decoder) { (response) in
                    guard let error = response.value else { return }
                    completionHandler(nil, error)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        break
                    case let .failure(error):
                        print("NETWORK: \(error.localizedDescription)")
                        completionHandler(nil, ErrorResponse(error: "Something went wrong!"))
                        break
                    }
                }
        } else {
            AF.request(self.baseURL+route, method: method, parameters: body, encoder: parameterEncoder, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                            AuthManager.authManager.signout()
                        } else if httpStatusCode == 204 || httpStatusCode == 200 || httpStatusCode == 201 || httpStatusCode == 405 {
                            completionHandler(EmptyResponse(success: "204"), nil)
                        } else {
                            print("NETWORK: OTHER NETWORK \(httpStatusCode)")
                        }
                    }
                }
                .responseDecodable(of: ErrorResponse.self, decoder: decoder) { (response) in
                    guard let error = response.value else { return }
                    completionHandler(nil, error)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        break
                    case let .failure(error):
                        print("NETWORK: \(error.localizedDescription)")
                        completionHandler(nil, ErrorResponse(error: "Something went wrong!"))
                        break
                    }
                }
        }
    }
}
