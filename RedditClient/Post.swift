//
//  Post.swift
//  RedditClient
//
//  Created by Rich Kolasa on 10/27/16.
//  Copyright © 2016 Rich Kolasa. All rights reserved.
//

import UIKit

struct Post {
    var title: String
    var author: String?
    var url: String?
    
    init(title: String, author: String?, url: String?) {
        self.title = title
        self.author = author
        self.url = url
    }
}
