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
    
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var avatarContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarContainerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var messageBubbleContainerView: UIView!
    @IBOutlet weak var messageBubbleContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageBubbleImageView: UIImageView!
    @IBOutlet weak var messageBubbleTopLabel: UILabel!
    @IBOutlet weak var messageBubbleTopLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewAvatarHorizontalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewBottomVerticalSpaceConstraint:NSLayoutConstraint!
    @IBOutlet weak var textViewMarginHorizontalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewTopVerticalSpaceConstraint: NSLayoutConstraint!
    
    
    var message: Message? {
        didSet {
            if let movieModel = message?.parsedPayload as? MoviePayload {
                textView.text = movieModel.title
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
