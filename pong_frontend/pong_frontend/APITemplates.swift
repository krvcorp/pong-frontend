//
//  APITemplates.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

// template for api calls. essentially replace objects with object.
struct Object: Codable, Hashable, Identifiable {
    var id: Int
}

class SomeViewModel: ObservableObject {
    @Published var objects: [Object] = []
    @Published var object: Object = Object(id: -1)
    
    // LIST OF OBJECTS
    func getObjects() {
        // url handler
        guard let url = URL(string: "url_goes_here") else { return }

        // task handler. [weak self] prevents memory leaks
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // convert to json. replaced Object w/ object
            do {
                let objects = try JSONDecoder().decode([Object].self, from: data)
                DispatchQueue.main.async {
                    self?.objects = objects
                }
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
        }
        // activates api call
        task.resume()
    }
    
    // SINGLE OBJECT
    func callAPI() {
        guard let url = URL(string: "url_goes_here") else { return }

        // task handler
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let data = data, error == nil else { return }
            
            // convert to json. replaced Object w/ object
            do {
                let object = try JSONDecoder().decode(Object.self, from: data)
                DispatchQueue.main.async {
                    self?.object = object
                }
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
        }
        // activates api call
        task.resume()
    }
}

// old single object api call that worked

//func callAPI(completion: @escaping (Post) -> ()) {
//    guard let url = URL(string: "http://127.0.0.1:8005/api/getPost/7/") else{
//        return
//    }
//
//
//    let task = URLSession.shared.dataTask(with: url){
//        data, response, error in
//
//        if let data = data, let string = String(data: data, encoding: .utf8){
//            print(string)
//
//            do {
//                let information = try JSONDecoder().decode(Post.self, from: data)
////                    print("DEBUG: \(information.id)")
////                    print("DEBUG: \(information.user)")
////                    print("DEBUG: \(information.title)")
////                    print("DEBUG: \(information.created_at)")
////                    print("DEBUG: \(information.updated_at)")
//
//                DispatchQueue.main.async {
//                    completion(information)
//                }
//
//            } catch {
//                print(error)
//            }
//
//        }
//    }
//
//    task.resume()
//}
//
//@State var post : Post = Post(id: 1, user: 2, title: "dub", created_at: "racism", updated_at: "ni")
