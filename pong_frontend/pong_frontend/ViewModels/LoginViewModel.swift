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

    func verifyEmail(idToken: String, phoneLoginVM: PhoneLoginViewModel) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let parameterEncoder = JSONParameterEncoder(encoder: encoder)
        
        let parameters: VerifyEmailRequestBody = VerifyEmailRequestBody(idToken: idToken, phone: phoneLoginVM.phone)
        
        let method = HTTPMethod.post
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request("\(API().root)verify-user/", method: method, parameters: parameters, encoder: parameterEncoder, headers: headers).responseDecodable(of: VerifyEmailResponseBody.self) { response in
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
