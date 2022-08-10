//import Foundation
//
//class ProfileCommentBubbleViewModel: ObservableObject {
//    @Published var post: Post = defaultPost
//
//    func deleteComment(comment_id: String) {
//        NetworkManager.networkManager.request(route: "comment/\(comment_id)/", method: .delete, successType: LoggedInUserInfoResponseBody.self) { successResponse in
//
//        }
//    }
//
//    func commentVote(id: String, vote: Int) {
//        guard let token = DAKeychain.shared["token"] else { return }
//        guard let url = URL(string: "\(API().root)commentvote/") else { return }
//
//        let body = CommentVoteRequestBody(comment_id: id, vote: vote)
//
//        var request = URLRequest(url: url)
////        if (currentDirection == 1 || currentDirection == -1) && direction != currentDirection {
////            request.httpMethod = "PATCH"
////        } else {
////            request.httpMethod = "POST"
////        }
//
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
//        let encoder = JSONEncoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        request.httpBody = try? encoder.encode(body)
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//
//            guard let _ = data, error == nil else {
//                return
//            }
//
//            // response stuff if it exists
////            let decoder = JSONDecoder()
////            decoder.keyDecodingStrategy = .convertFromSnakeCase
////            guard let loginResponse = try? decoder.decode(Post.self, from: data) else {
////                completion(.failure(.invalidCredentials))
////                return
////            }
////
////            completion(.success(loginResponse.title))
//
//        }.resume()
//    }
//
//    // this logic should probably go into feedviewmodel where tapping on a post calls an API to get updated post information regarding a post
//    func readPost(postId: String) -> Void {
//
//        print("DEBUG: PostBubbleVM readPost \(postId)")
//
//        guard let token = DAKeychain.shared["token"] else { return }
//        guard let url = URL(string: "\(API().root)post/\(postId)/") else {
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            guard let data = data, error == nil else {
//                return
//            }
//
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            guard let postResponse = try? decoder.decode(Post.self, from: data) else {
//                return
//            }
//            DispatchQueue.main.async {
//                // replace the local post
//                self.post = postResponse
//            }
//        }.resume()
//    }
//}
