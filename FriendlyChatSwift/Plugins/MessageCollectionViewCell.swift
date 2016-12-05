//
//  MessageCollectionViewCell.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 12/4/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var messageBubbleContainerView: UIView!
    @IBOutlet weak var messageBubbleImageView: UIImageView!
    @IBOutlet weak var messageBubbleTopLabel: UILabel!
    @IBOutlet weak var messageBubbleTopLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftAvatarSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightAvatarSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftAvatarImageView: UIImageView!
    @IBOutlet weak var rightAvatarImageView: UIImageView!
    
    var message: Message?
    
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
        contentLeadingConstraint.constant = isIncomingMessage ? 10: 5
        contentTrailingConstraint.constant = isIncomingMessage ? 5: 10
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
