import Foundation

class ProfileCommentBubbleViewModel: ObservableObject {
    func deleteComment(comment_id: String) {
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)comment/" + comment_id + "/") else { return }
        
//        let body = DeleteCommentRequestBody(comment_id: comment_id)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
//        request.httpBody = try? encoder.encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else { return }
//            TODO: Decode delete comment response and create potential error based on something like "Comment could not be deleted for X/Y/Z"
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            guard let commentResponse = try? decoder.decode(Comment.self, from: data) else { return }
            
        }.resume()
    }
    
    func commentVote(id: String, vote: Int) {
        guard let token = DAKeychain.shared["token"] else { return }
        guard let url = URL(string: "\(API().root)commentvote/") else { return }
        
        let body = CommentVoteRequestBody(comment_id: id, vote: vote)
        
        var request = URLRequest(url: url)
//        if (currentDirection == 1 || currentDirection == -1) && direction != currentDirection {
//            request.httpMethod = "PATCH"
//        } else {
//            request.httpMethod = "POST"
//        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                return
            }
            
            // response stuff if it exists
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            guard let loginResponse = try? decoder.decode(Post.self, from: data) else {
//                completion(.failure(.invalidCredentials))
//                return
//            }
//
//            completion(.success(loginResponse.title))
            
        }.resume()
    }
}
