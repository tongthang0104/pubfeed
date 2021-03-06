//
//  Like.swift
//  PubFeed
//
//  Created by Jay Maloney on 1/6/16.
//  Copyright © 2016 Mike Gilroy. All rights reserved.
//

import Foundation

struct Like: Equatable, FirebaseType {
    
    private let UserIDKey = "userIdentifier"
    private let PostIDKey = "postIdentifier"
    private let IdentifierKey = "identifier"
    
    var userIdentifier: String
    var postIdentifier: String
    var identifier: String?
    
    init(userIdentifier: String, postIdentifier: String, identifier: String? = nil) {
        
        self.userIdentifier = userIdentifier
        self.postIdentifier = postIdentifier
        self.identifier = identifier
    }
    
    
    // Mark: FirebaseType
    
    var endpoint: String {
        return "likes/\(self.userIdentifier)"
    }
    
    var jsonValue: [String: AnyObject] {
        
        var json: [String: AnyObject] = [UserIDKey: userIdentifier, PostIDKey: postIdentifier]
        if let identifier = identifier {
            json.updateValue(identifier, forKey: IdentifierKey)
        }
        return json
    }
    
    
    init?(json: [String:AnyObject], identifier: String) {
        
        guard let postIdentifier = json[PostIDKey] as? String,
            
            let userIdentifier = json[UserIDKey] as? String else { return nil }
        
        self.postIdentifier = postIdentifier
        self.userIdentifier = userIdentifier
        self.identifier = identifier
    }
}


func ==(lhs: Like, rhs: Like) -> Bool {
    
    return (lhs.identifier == rhs.identifier) && (lhs.postIdentifier == rhs.postIdentifier)
}
