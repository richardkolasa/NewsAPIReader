//
//  SourceCell.swift
//  RedditClient
//
//  Created by Rich Kolasa on 12/19/16.
//  Copyright © 2016 Rich Kolasa. All rights reserved.
//

import UIKit
import IGListKit
import Hero

protocol Sourceable {
    func setup(source: Source)
}

class SourceCell: UICollectionViewCell, Sourceable {
    
    @IBOutlet weak var name: UILabel!
    
    func setup(source: Source) {
        name.text = source.name
    }
}
