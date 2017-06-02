//
//  SourceService.swift
//  RedditClient
//
//  Created by Rich Kolasa on 12/19/16.
//  Copyright © 2016 Rich Kolasa. All rights reserved.
//

import Foundation
import Alamofire
import Marshal

class SourceService {
    
    let topUrlString = "https://newsapi.org/v1/sources?language=en"
    var sources: [Source] = []
    
    func get(source: String = "", finished: @escaping ([Source]) -> Void) {
        Alamofire
            .request(topUrlString)
            .validate()
            .responseJSON { response in
                
            guard response.result.isSuccess else {
                print("error parsing json")
                return
            }
            
            guard let value = response.result.value as? [String: Any],
                let sourcesDict = value["sources"] as? [[String: Any]] else {
                    return
            }
            
            
            for item in sourcesDict {
                do {
                    let source = try Source(jsonRepresentation: item)
                    self.sources.append(source)
                }
                catch {
                    print("didnt work")
                }
            }
            
            finished(self.sources)
        }
    }
}
