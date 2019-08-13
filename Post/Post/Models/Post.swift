//
//  Post.swift
//  Post
//
//  Created by Ian Hall on 8/12/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import Foundation

struct Post: Codable{
    var text: String
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    var username: String
    
    var queryTimestamp: TimeInterval {
        return timestamp + 0.00001
    }
}
