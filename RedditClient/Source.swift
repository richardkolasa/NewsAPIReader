//
//  Source.swift
//  RedditClient
//
//  Created by Rich Kolasa on 12/19/16.
//  Copyright © 2016 Rich Kolasa. All rights reserved.
//

import UIKit
import Marshal
import IGListKit

class Source: JSONDeserializable {
    var name: String
    var id: String
    var descriptionText: String
    
    required init(jsonRepresentation: JSON) throws {
        guard let name = jsonRepresentation["name"] as? String,
            let id = jsonRepresentation["id"] as? String,
            let descriptionText = jsonRepresentation["description"] as? String else {
                throw JSONDeserializationError.missingAttribute("")
        }
        
        self.name = name
        self.id = id
        self.descriptionText = descriptionText
    }
}

extension Source: CustomStringConvertible {
    public var description: String {
        return "name: \(self.name) id: \(self.id)"
    }
}

extension Source: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Source else {
            return false
        }
        
        if id != object.id || name != object.name {
            return false
        }
        return true
    }
}
