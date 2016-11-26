//
//  MovieCellTableViewCell.swift
//  FriendlyChatSwift
//
//  Created by Harshit Mapara on 11/25/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit

class MovieCellTableViewCell: UITableViewCell {
    public static let reuseID = "MovieCellReuseId"

    @IBOutlet weak var movieThumbnailImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
