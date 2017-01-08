//
//  GroupsTableViewCell.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 11/24/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {
    public static let cellHeight:CGFloat = 80
    public static let reuseID = "GroupsTableViewCellReuseIdentifier"
    public var group: Group? {
        didSet {
            if let groupTitle = group?.title,
               let currentUserName = FirebaseUtils.sharedInstance.authUser?.displayName {
                var newTitle = groupTitle.replacingOccurrences(of: currentUserName, with: "")
                if (newTitle == "") {
                    newTitle = "Selfie Chat"
                }
                self.groupTitle.text = newTitle
                
                lastMessageSnippetLabel.text = group?.lmSnippet
               
                if let lmTimeStamp = group?.ts {
                    let lmDate = Date(timeIntervalSince1970: (lmTimeStamp/1000));
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "E MMM dd, yyyy"
                    lastMessageTimeStampLabel.text = dateFormatter.string(from: lmDate)
                }
                updateImageViewWithImage(image: nil)
            } else {
                self.groupTitle.text = ""
            }
        }
    }
    private var imageProvider: ImageProvider?
    
    @IBOutlet weak var groupAvatarImageView: UIImageView!
    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var lastMessageSnippetLabel: UILabel!
    @IBOutlet weak var lastMessageTimeStampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        groupAvatarImageView.layer.cornerRadius = 25.0
        groupAvatarImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fetchImage() {
        if let groupImageUrl = self.group?.groupImageURL {
            imageProvider = ImageProvider(withImageURL: groupImageUrl, completion: { (fetchedImage) in
                OperationQueue.main.addOperation {
                    self.updateImageViewWithImage(image: fetchedImage)
                }
            })
        }
    }
    
    func cancelImageFetching() {
        if let imageProvider = self.imageProvider {
            imageProvider.cancel()
            self.imageProvider = nil
        }
    }
    
    func updateImageViewWithImage(image: UIImage?) {
        if let image = image {
            groupAvatarImageView.image = image
            groupAvatarImageView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.groupAvatarImageView.alpha = 1.0
//                self.activityIndicator.alpha = 0
            }, completion: {
                _ in
//                self.activityIndicator.stopAnimating()
            })
            
        } else {
            groupAvatarImageView.image = nil
            groupAvatarImageView.alpha = 0
//            activityIndicator.alpha = 1.0
//            activityIndicator.startAnimating()
        }
    }
    
}
