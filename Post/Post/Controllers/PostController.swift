//
//  PostController.swift
//  Post
//
//  Created by Ian Hall on 8/12/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import Foundation

class PostController {
    
    let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    var posts:[Post] = []
    
    func fetchPosts(reset: Bool = true, completion: @escaping () -> Void){
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        guard let unwrappedUrl = baseURL else {return}
        let urlParameters = ["orderBy": "\"timestamp\"", "endAt": "\(queryEndInterval)", "limitToLast" : "15"]
        let queryItems = urlParameters.compactMap({URLQueryItem(name: $0.key, value: $0.value)})
        var urlComponents = URLComponents(url: unwrappedUrl, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else {return}
        
        let getterEndpoint = url.appendingPathExtension("json")
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        let _ = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error{
                print("error fetching post\(error)")
                completion()
                return
            }
            guard let data = data else {return}
            do{
                let postsDictionary = try JSONDecoder().decode([String : Post].self, from: data)
                var posts = postsDictionary.compactMap({$0.value})
                posts.sort(by: {$0.timestamp > $1.timestamp})
                if reset {
                self.posts = posts
                } else {
                    self.posts.append(contentsOf: posts)
                }
                completion()
                return
            } catch {
                print(error)
                completion()
                return
            }
            
            }.resume()
    }
    func addNewPostWith(username: String, text: String, completion: @escaping() -> Void) {
        let post = Post(text: text, timestamp: Date().timeIntervalSince1970, username: username)
        var postData: Data
        do{
            let data = try JSONEncoder().encode(post)
            postData = data
        } catch {
            print("error encoding \(error.localizedDescription)")
            completion()
            return
        }
        guard let postEndpoint = baseURL else {return}
        let url = postEndpoint.appendingPathExtension("json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error{
                print("error in URLSESSIONDATATASK \(error.localizedDescription)")
                completion()
                return
            }
            guard let data = data else {return}
            print(String(data: data, encoding: .utf8)!)
            print("succesfully captured data")
            self.posts.append(post)
            self.fetchPosts(completion: {
                completion()
            })
            }.resume()
    }
}




