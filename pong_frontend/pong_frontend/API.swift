//
//  API.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

enum AuthenticationError: Error {
    case invalidCredentials
    case custom(errorMessage: String)
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

struct LoginResponse: Codable {
    let token: String?
    let message: String?
    let success: Bool?
}

struct PostRequestBody: Codable {
    let title: String
}

struct OTPStartRequestBody: Codable {
    let phone: String
}

struct OTPStartResponseBody: Codable {
    let newUser: Bool?
    let phone: String?
}

struct OTPVerifyRequestBody: Codable {
    let phone: String
    let code: String
}

// token : String, new_user : Bool, code_expire : Bool, code_incorrect : Bool
struct OTPVerifyResponseBody: Codable {
    let token: String?
    let emailUnverified: Bool?
    let codeExpire: Bool?
    let codeIncorrect: Bool?
}

struct VerifyEmailRequestBody: Codable {
    let phone: String
    let email: String
}

struct VerifyEmailResponseBody: Codable {
    let token: String?
}

struct LoggedInUserInfoResponseBody: Codable {
    let id: String
    let email: String
    let posts: [Post]
    let comments: [Comment]
    let inTimeout: Bool
    let phone: String
    let totalKarma: Int
    let commentKarma: Int
    let postKarma: Int
    
}

class API: ObservableObject {
    var root: String = "http://localhost:8005/api/"
    @Published var posts: [Post] = []
    
    func getPosts() {
        print("DEBUG: API getPosts")
        
        guard let token = DAKeychain.shared["token"] else { return } // Fetch
        
        // url handler
        guard let url = URL(string: "\(root)" + "post/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        // task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // convert to json
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let posts = try decoder.decode([Post].self, from: data)
                DispatchQueue.main.async {
                    self?.posts = posts
                }
            } catch {
                print("DEBUG: \(error)")
            }
        }
        // activates api call
        task.resume()
    }
    
    func otpStart(phone: String, completion: @escaping (Result<Bool, AuthenticationError>) -> Void) {
        print("DEBUG: API otpStart \(phone)")
        
        // change URL to real login
        guard let url = URL(string: "\(root)" + "otp-start/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = OTPStartRequestBody(phone: phone)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            guard let otpStartResponse = try? JSONDecoder().decode(OTPStartResponseBody.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            guard let new_user = otpStartResponse.newUser else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            completion(.success(new_user))
            
        }.resume()
    }
    
    func otpVerify(phone: String, code: String, completion: @escaping (Result<OTPVerifyResponseBody, AuthenticationError>) -> Void) {
        // change URL to real login
        guard let url = URL(string: "\(root)" + "otp-verify/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = OTPVerifyRequestBody(phone: phone,code: code)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            guard let otpVerifyResponse = try? decoder.decode(OTPVerifyResponseBody.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            print("DEBUG: API otpVerifyResponse is \(otpVerifyResponse)")
            
            // token : String, new_user : Bool, code_expire : Bool, code_incorrect : Bool
            if let responseDataContent = otpVerifyResponse.token {
                print("DEBUG: API Token is \(responseDataContent)")
                completion(.success(otpVerifyResponse))
                return
            }
            
            if let responseDataContent = otpVerifyResponse.emailUnverified {
                print("DEBUG: API email_unverified is \(responseDataContent)")
                completion(.success(otpVerifyResponse))
                return
            }
            
            if let responseDataContent = otpVerifyResponse.codeExpire {
                print("DEBUG: code_expire is \(responseDataContent)")
                completion(.success(otpVerifyResponse))
                return
            }
            
            if let responseDataContent = otpVerifyResponse.codeIncorrect {
                print("DEBUG: code_incorrect is \(responseDataContent)")
                completion(.success(otpVerifyResponse))
                return
            }
            
            print("DEBUG: API \(otpVerifyResponse)")
            completion(.failure(.custom(errorMessage: "Broken")))
            
        }.resume()
    }
    
    func verifyEmail(phone: String, email: String, completion: @escaping (Result <String, AuthenticationError>) -> Void ) {
        guard let url = URL(string: "\(root)" + "verify-user/") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        let body = VerifyEmailRequestBody(phone: phone, email: email)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            guard let verifyEmailResponse = try? JSONDecoder().decode(VerifyEmailResponseBody.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            print("DEBUG: API otpVerifyResponse is \(verifyEmailResponse)")
            
            // token : String, new_user : Bool, code_expire : Bool, code_incorrect : Bool
            if let responseDataContent = verifyEmailResponse.token {
                print("DEBUG: API Token is \(responseDataContent)")
                completion(.success(verifyEmailResponse.token!))
                return
            }
            
            
            print("DEBUG: API \(verifyEmailResponse.token!)")
            completion(.failure(.custom(errorMessage: "new_user not returned. Consider code_expire or code_incorrect")))
            
        }.resume()
        
    }
    
    func getLoggedInUserInfo(id: String, completion: @escaping (Result<LoggedInUserInfoResponseBody, AuthenticationError>) -> Void) {
        guard let url = URL(string: "\(root)" + "user/" + id) else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token 50af864e998ac9340d775b9547e5577edd7497ee", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            guard let loggedInUserInfoResponse = try? JSONDecoder().decode(LoggedInUserInfoResponseBody.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            print("DEBUG: API otpVerifyResponse is \(loggedInUserInfoResponse)")
            completion(.success(loggedInUserInfoResponse))
            
        }.resume()
    }
}
