//
//  MovieCollectionViewCell.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 12/3/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MovieMessageCollectionViewCell: UICollectionViewCell {
    public static let cellReuseIdentifier = "MovieMessageCollectionViewCellIdentifier"
    public static let xibFileName = "MovieMessageCollectionViewCell"
    
    
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
    
    @IBOutlet weak var leftAvatarSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightAvatarSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftAvatarImageView: UIImageView!
    @IBOutlet weak var rightAvatarImageView: UIImageView!
    
    
    var message: Message? {
        didSet {
            if let movieModel = message?.parsedPayload as? MoviePayload {
                textView.text = movieModel.title
            }
        }
    }
    
    func configureCellWith(avatarDataSource: JSQMessageAvatarImageDataSource?, bubbleImageDataSource: JSQMessageBubbleImageDataSource?, isIncomingMessage: Bool, topSpacing: CGFloat) {
        
        messageBubbleImageView.image = bubbleImageDataSource?.messageBubbleImage()
        messageBubbleImageView.highlightedImage = bubbleImageDataSource?.messageBubbleHighlightedImage()
        messageBubbleTopLabelHeightConstraint.constant = topSpacing
        
        let activeAvatarImageView = isIncomingMessage ? leftAvatarImageView : rightAvatarImageView
        let passiveAvatarImageView = isIncomingMessage ? rightAvatarImageView : leftAvatarImageView
        
        passiveAvatarImageView?.isHidden = true
        activeAvatarImageView?.image = avatarDataSource?.avatarImage()
        activeAvatarImageView?.highlightedImage = avatarDataSource?.avatarHighlightedImage()
        activeAvatarImageView?.isHidden = false
        
        leftAvatarSpacingConstraint.priority = isIncomingMessage ? 751 : 750
        rightAvatarSpacingConstraint.priority = isIncomingMessage ? 750 : 751
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
