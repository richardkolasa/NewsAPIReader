//
//  JSONService.swift
//  RedditClient
//
//  Created by Rich Kolasa on 10/27/16.
//  Copyright © 2016 Rich Kolasa. All rights reserved.
//

import Foundation
import Alamofire
import Marshal

enum Result<T> {
    case success(T)
    case failure(Error)
}

protocol Gettable {
    
    func get(sourceID: String, finished: @escaping ([Post]) -> Void)
}

enum ServiceError: Error {
    case postError
}

struct PostService: Gettable {
    
    func get(sourceID: String = (UserDefaults.standard.object(forKey: "sourceID") as? String)!,
             finished: @escaping ([Post]) -> Void) {
        
        guard let url = createURLWithComponents(sourceID: sourceID) else {
            return
        }
        
        Alamofire.request(url).responseJSON { response in
            var posts = [Post]()
            guard
                let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let articles = json?["articles"] as? [[String: AnyObject]] else {
                    return
            }
            
            for article in articles {
                if let title = article["title"] as? String {
                    let author = article["author"] as? String
                    let url = article["url"] as? String
                    
                    let post = Post(title: title, author: author, url: url)
                    posts.append(post)
                } else {
                    print("could not determine article title")
                }
            }
            finished(posts)
        }
    }
    
    func createURLWithComponents(sourceID: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "newsapi.org"
        urlComponents.path = "/v1/articles"
        urlComponents.query = "=\(sourceID)&sortBy=top&apiKey=3ea7b7c7c96e4740a5a62f1ea5cfeced"
        
        return urlComponents.url
    }
}
