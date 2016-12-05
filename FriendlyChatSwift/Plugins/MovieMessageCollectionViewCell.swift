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
    public static let rawHeight:CGFloat = 280
    
    @IBOutlet weak var messageBubbleContainerView: UIView!
    @IBOutlet weak var messageBubbleContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageBubbleImageView: UIImageView!
    @IBOutlet weak var messageBubbleTopLabel: UILabel!
    @IBOutlet weak var messageBubbleTopLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var movieImageView: UIImageView!
    
    @IBOutlet weak var leftAvatarSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightAvatarSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftAvatarImageView: UIImageView!
    @IBOutlet weak var rightAvatarImageView: UIImageView!
    
    var imageRequest: URLRequest?
    var movieModel: MoviePayload?
    
    var message: Message? {
        didSet {
            movieModel = message?.parsedPayload as? MoviePayload
            if let movieModel = movieModel {
                let baseUrl = "http://image.tmdb.org/t/p/w500"
                imageRequest = URLRequest(url: URL(string: baseUrl + movieModel.poster_path!)!)
                
                self.movieImageView.setImageWith(imageRequest!, placeholderImage: nil, success: { (imageRequest, imageResponse, image) in
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        self.movieImageView.alpha = 0.0
                        self.movieImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.movieImageView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        self.movieImageView.image = image
                    }
                    }, failure: { (imageRequest, iresponse, error) in
                        print("image fetch error \(error.localizedDescription)")
                })
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
        contentLeadingConstraint.constant = isIncomingMessage ? 10: 5
        contentTrailingConstraint.constant = isIncomingMessage ? 5: 10
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        print ("KEVINDEBUG I am touched \(self.movieModel?.title)")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        movieImageView.layer.cornerRadius = 15.0
        movieImageView.clipsToBounds = true
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        movieImageView.addGestureRecognizer(tapGr)
        movieImageView.isUserInteractionEnabled = true
    }
}
