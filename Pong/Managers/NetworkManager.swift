import Foundation
import Alamofire

class NetworkManager: ObservableObject {
    
    static let networkManager = NetworkManager()
    
    // MARK: BaseURL
    #if DEBUG
        var baseURL = "http://localhost:8005/api/"
        var rootURL = "http://localhost:8005/"
    #else
        var baseURL = "https://pong.college/api/"
        var rootURL = "https://pong.college/"
    #endif
    
    // MARK: Empty / Error Structs
    struct EmptyBody: Encodable {}
    struct EmptyResponse: Codable {
        var success: String
    }
    struct ErrorResponse: Codable {
        var error: String
    }
    
    // MARK: Encoder / Decoder
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
        
        // MARK: Get
        if(method == .get) {
            AF.request(self.baseURL+route, method: method, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        // AUTHENTICATION ERROR
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                            AuthManager.authManager.signout(force: true)
                        }
                        // RANDOM ERRORS
                        else if httpStatusCode > 401 && httpStatusCode < 600 {
                            print("NETWORK: \(httpStatusCode) error")
                            ToastManager.shared.errorToastDetected(message: "Something went wrong!", subMessage: "Unable to connect to network")
                            completionHandler(nil, ErrorResponse(error: "Something went wrong!"))
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
                    ToastManager.shared.errorPopupDetected(message: (error.error))
                    completionHandler(nil, error)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        break
                    case let .failure(error):
                        print("NETWORK: \(error.localizedDescription)")
                        ToastManager.shared.errorToastDetected(message: "Something went wrong!", subMessage: "Unable to connect to network")
                        completionHandler(nil, ErrorResponse(error: "Something went wrong!"))
                        break
                    }
                }
        }
        // MARK: Not Get
        else {
            AF.request(self.baseURL+route, method: method, parameters: body, encoder: parameterEncoder, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        // AUTHENTICATION ERROR
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                            AuthManager.authManager.signout(force: true)
                        }
                        // RANDOM ERRORS
                        else if httpStatusCode > 401 && httpStatusCode < 600 {
                            print("NETWORK: \(httpStatusCode) error")
                            ToastManager.shared.errorToastDetected(message: "Something went wrong!", subMessage: "Unable to connect to network")
                        }
                    }
                }
                .responseDecodable(of: successType, decoder: decoder) { (response) in
                    guard let success = response.value else { return }
                    completionHandler(success, nil)
                }
                .responseDecodable(of: ErrorResponse.self, decoder: decoder) { (response) in
                    guard let error = response.value else { return }
                    ToastManager.shared.errorPopupDetected(message: (error.error))
                    completionHandler(nil, error)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        break
                    case let .failure(error):
                        print("NETWORK: \(error.localizedDescription)")
                        ToastManager.shared.errorToastDetected(message: "Something went wrong!", subMessage: "Unable to connect to network")
                        completionHandler(nil, ErrorResponse(error: "Something went wrong!"))
                        break
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
        
        // MARK: Get
        if(method == .get) {
            AF.request(self.baseURL+route, method: method, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        print("NETWORK: \(httpStatusCode)")
                        // AUTHENTICATION ERROR
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                            AuthManager.authManager.signout(force: true)
                        }
                        // RANDOM ERRORS
                        else if httpStatusCode > 401 && httpStatusCode < 600 {
                            print("NETWORK: \(httpStatusCode) error")
                            ToastManager.shared.errorToastDetected(message: "Something went wrong!", subMessage: "Unable to connect to network")
                        }
                        // DESIRED OUTCOME
                        else if httpStatusCode == 204 || httpStatusCode == 200 || httpStatusCode == 201 {
                            completionHandler(EmptyResponse(success: "204"), nil)
                        }
                    }
                }
                .responseDecodable(of: ErrorResponse.self, decoder: decoder) { (response) in
                    guard let error = response.value else { return }
                    ToastManager.shared.errorPopupDetected(message: (error.error))
                    completionHandler(nil, error)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        break
                    case let .failure(error):
                        print("NETWORK: \(error.localizedDescription)")
                        ToastManager.shared.errorToastDetected(message: "Something went wrong!", subMessage: "Unable to connect to network")
                        completionHandler(nil, ErrorResponse(error: "Something went wrong!"))
                        break
                    }
                }
        }
        // MARK: Not Get
        else {
            AF.request(self.baseURL+route, method: method, parameters: body, encoder: parameterEncoder, headers: httpHeaders)
                .response() { (response) in
                    if let httpStatusCode = response.response?.statusCode {
                        // AUTHENTICATION ERROR
                        if httpStatusCode == 401 {
                            print("NETWORK: 401 Error")
                            AuthManager.authManager.signout(force: true)
                        }
                        // RANDOM ERRORS
                        else if httpStatusCode > 401 && httpStatusCode < 600 {
                            print("NETWORK: \(httpStatusCode) error")
                            ToastManager.shared.errorToastDetected(message: "Something went wrong!", subMessage: "Unable to connect to network")
                        }
                        // DESIRED OUTCOME
                        else if httpStatusCode == 204 || httpStatusCode == 200 || httpStatusCode == 201 {
                            completionHandler(EmptyResponse(success: "204"), nil)
                        }
                    }
                }
                .responseDecodable(of: ErrorResponse.self, decoder: decoder) { (response) in
                    guard let error = response.value else { return }
                    ToastManager.shared.errorPopupDetected(message: (error.error))
                    completionHandler(nil, error)
                }
                .responseData() { (response) in
                    switch response.result {
                    case .success:
                        break
                    case let .failure(error):
                        print("NETWORK: \(error.localizedDescription)")
                        ToastManager.shared.errorToastDetected(message: "Something went wrong!", subMessage: "Unable to connect to network")
                        completionHandler(nil, ErrorResponse(error: "Something went wrong!"))
                        break
                    }
                }
        }
    }
}
