//
//  GroupsTableViewCell.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 11/24/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {
    public static let reuseID = "GroupsTableViewCellReuseIdentifier"
    public var group: Group? {
        didSet {
            self.groupTitle.text = group?.title
        }
    }
    
    @IBOutlet weak var groupTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
