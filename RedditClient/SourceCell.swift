//
//  SourceCell.swift
//  RedditClient
//
//  Created by Rich Kolasa on 12/19/16.
//  Copyright © 2016 Rich Kolasa. All rights reserved.
//

import UIKit
import IGListKit

protocol Sourceable {
    func setup(source: Source)
}

class SourceCell: UICollectionViewCell, Sourceable {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setup(source: Source) {
        name.text = source.name
    }
}
