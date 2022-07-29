//
//  LoginViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 6/27/22.
//


import Foundation
import GoogleSignIn
import Alamofire

// main actor allows observable object to run in the main queue
@MainActor class LoginViewModel: ObservableObject {
    @Published var password: String = ""
    @Published var gmailString: String = ""
    @Published var initialOnboard: Bool = false
    
    func signout() {
        DispatchQueue.main.async {
            self.gmailString = ""
            self.password = ""
            self.initialOnboard = true
            GIDSignIn.sharedInstance.disconnect()
            DAKeychain.shared["userId"] = nil
            DAKeychain.shared["token"] = nil
        }
    }
    
//    func verifyEmail(idToken: String, phoneLoginVM: PhoneLoginViewModel) {
//        guard let url = URL(string: "\(API().root)" + "verify-user/") else {return}
//
//        let body = VerifyEmailRequestBody(idToken: idToken, phone: phoneLoginVM.phone)
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        let encoder = JSONEncoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        request.httpBody = try? encoder.encode(body)
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            // handle response from backend
//            guard let data = data, error == nil else {return}
//
//            guard let verifyEmailResponse = try? JSONDecoder().decode(VerifyEmailResponseBody.self, from: data) else {return}
//
//            print("DEBUG: API otpVerifyResponse is \(verifyEmailResponse)")
//
//            DispatchQueue.main.async {
//                if let token = verifyEmailResponse.token {
//                    DAKeychain.shared["token"] = token
//                }
//                if let userId = verifyEmailResponse.userId {
//                    DAKeychain.shared["userId"] = userId
//                }
//                // resets phoneLoginVM and authenticates user
//                phoneLoginVM.phone = ""
//                phoneLoginVM.phoneIsProvided = false
//                phoneLoginVM.phoneIsVerified = false
//                phoneLoginVM.code = ""
//            }
//        }.resume()
//    }
    func verifyEmail(idToken: String, phoneLoginVM: PhoneLoginViewModel) {
        let parameters: VerifyEmailRequestBody = VerifyEmailRequestBody(idToken: idToken, phone: phoneLoginVM.phone)
        
        let method = HTTPMethod.post
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let parameterEncoder = JSONParameterEncoder(encoder: encoder)
        
        AF.request("\(API().root)block/", method: method, parameters: parameters, encoder: parameterEncoder, headers: headers).responseDecodable(of: VerifyEmailResponseBody.self) { response in
            print("DEBUG: loginVM verifyEmail response: \(response)")
            switch response.result {
            case .success(let successResponse):
                print("DEBUG: loginVM verifyEmail successResponse: \(successResponse)")
                
                DispatchQueue.main.async {
                    if let token = successResponse.token {
                        DAKeychain.shared["token"] = token
                    }
                    if let userId = successResponse.userId {
                        DAKeychain.shared["userId"] = userId
                    }
                    // resets phoneLoginVM and authenticates user
                    phoneLoginVM.phone = ""
                    phoneLoginVM.phoneIsProvided = false
                    phoneLoginVM.phoneIsVerified = false
                    phoneLoginVM.code = ""
                }
            case .failure(let failureResponse):
                print("DEBUG: loginVM verifyEmail failureResponse: \(failureResponse)")
            }
        }
    }
}
