//
//  APITemplates.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//
// there is slightly different style in the GET and POST API calls. note that the get stored values in the class
// itself. the post returns values in a completetion and additional data handling is required wherever the function is
// called. see PhoneLoginViewModel for a decent example of this

import Foundation

// template for api calls. essentially replace objects with object.
struct Object: Codable, Hashable, Identifiable {
    var id: Int
}

class SomeViewModel: ObservableObject {
    // initialize with default values for data to be stored
    @Published var objects: [Object] = []
    @Published var object: Object = Object(id: -1)
    
    
    //
    //
    // GET requests
    //
    //
    
    // GET LIST OF OBJECTS
    func getObjects() {
        // url handler
        guard let url = URL(string: "url_goes_here") else { return }

        // task handler/execute. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            // if data is returned, store data, else leave
            guard let data = data, error == nil else { return }
            
            // convert to json. replaced Object w/ object
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let objects = try decoder.decode([Object].self, from: data)
                DispatchQueue.main.async {
                    self?.objects = objects
                }
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
            
            // above is generally equivalent to below
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let object = try? decoder.decode(Object.self, from: data) else {
                print("DEBUG: custom error there is no way to identify error")
                return
            }
            // store data retrieved
            DispatchQueue.main.async {
                self?.object = object
            }
        }
        // activates api call
        task.resume()
    }
    
    // GET SINGLE OBJECT
    func getObject() {
        guard let url = URL(string: "url_goes_here") else { return }

        // task handler
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // convert to json. replaced Object w/ object
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let object = try decoder.decode(Object.self, from: data)
                DispatchQueue.main.async {
                    self?.object = object
                }
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
            
            // above is generally equivalent to
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let object = try? decoder.decode(Object.self, from: data) else {
                print("DEBUG: custom error there is no way to identify error")
                return
            }
            DispatchQueue.main.async {
                self?.object = object
            }
            
        }
        // activates api call
        task.resume()
    }
    
    //
    //
    // POST request
    //
    //
    
    // create swift models
    struct SomeRequestBody : Codable {
        let input: String?
    }
    
    struct SomeResponseBody : Codable {
        let output: String?
    }
    
    // POST request function
    // completion returns whatever you want. ie the function has a completion of a string would return a string upon completion
    func postObject(input: String, completion: @escaping (Result<SomeResponseBody, AuthenticationError>) -> Void) {
        print("DEBUG: POST \(input)")
        
        // change URL to real login
        guard let url = URL(string: "url_goes_here") else {
            completion(.failure(.custom(errorMessage: "URL is not correct")))
            return
        }
        
        // constructing the request
        let body = SomeRequestBody(input: "Input")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // json encoding snake case/camel case handled
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? JSONEncoder().encode(body)
        
        // execute request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // check if request returns data
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            // json decoding snake case/came case handled
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let someResponseBody = try? JSONDecoder().decode(SomeResponseBody.self, from: data) else {
                completion(.failure(.decodeError))
                return
            }
            
            // return the response if it exists
            if let responseDataContent = someResponseBody.output {
                print("DEBUG: API output is \(responseDataContent)")
                completion(.success(someResponseBody))
                return
            }
            
            // create multiple for different types of responses
            if let responseDataContent = someResponseBody.output {
                print("DEBUG: API output is \(responseDataContent)")
                completion(.success(someResponseBody))
                return
            }
            
            // some other response that is not handled is a failure
            print("DEBUG: API \(someResponseBody)")
            completion(.failure(.custom(errorMessage: "Broken")))
            
        }.resume() // activate api call
    }
}
