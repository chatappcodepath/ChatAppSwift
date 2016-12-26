//
//  UserTableViewCell.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 12/23/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    public static let cellHeight:CGFloat = 70
    public static let reuseID = "UserTableViewCellReuseIdentifier"
    public static let nibName = "UserTableViewCell"
    
    public var displayUser: LZUser? {
        didSet {
            userNameLabel.text = displayUser?.name
            userEmailLabel.text = displayUser?.email
        }
    }
    
    private var imageProvider: ImageProvider?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userPhotoImageView.layer.cornerRadius = 25.0
        userPhotoImageView.clipsToBounds = true
    }
    
    func fetchImage() {
        if let userImageUrl = URL(string: (self.displayUser?.photoUrl)!) {
            imageProvider = ImageProvider(withImageURL: userImageUrl, completion: { (fetchedImage) in
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
            userPhotoImageView.image = image
            userPhotoImageView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.userPhotoImageView.alpha = 1.0
            }, completion: nil)
            
        } else {
            userPhotoImageView.image = nil
            userPhotoImageView.alpha = 0
        }
    }
}
