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
    
    func fetchPosts(completion: @escaping () -> Void){
        guard let unwrappedUrl = baseURL else {return}
        let getterEndpoint = unwrappedUrl.appendingPathExtension("json")
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
                self.posts = posts
                completion()
                return
            } catch {
                print(error)
                completion()
                return
            }
    
        }.resume()
        
        
//        var builtUrl = URLRequest(url: baseURL)
//        builtUrl.httpMethod = "GET"
//        URLSession.shared.dataTask(with: builtUrl) { (data, _,error) in
//            if let error = error{
//                print("error fething a card \(error)")
//                completion(nil); return
//            }
//            guard let data =  data else {return}
//            do {
//                let post = try JSONDecoder().decode(Post.self, from: data)
//                completion(post)
//            } catch {
//                print(error)
//
//            }
//            }.resume()
    }
    
    
}

