//
//  MovieCollectionCell.swift
//  FriendlyChatSwift
//
//  Created by Harshit Mapara on 11/26/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit

class MovieCollectionCell: UICollectionViewCell {
    public static let reuseID = "MovieCollectionCellReuseId"

    @IBOutlet weak var moveThumbnailView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
