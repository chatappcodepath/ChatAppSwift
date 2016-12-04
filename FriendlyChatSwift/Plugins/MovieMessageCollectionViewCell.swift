//
//  MovieCollectionViewCell.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 12/3/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit

class MovieMessageCollectionViewCell: UICollectionViewCell {
    public static let cellReuseIdentifier = "MovieMessageCollectionViewCellIdentifier"
    public static let xibFileName = "MovieMessageCollectionViewCell"
    
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    var message: Message? {
        didSet {
            if let movieModel = message?.parsedPayload as? MoviePayload {
                contentLabel.text = movieModel.title
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
