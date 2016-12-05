//
//  MovieCollectionViewCell.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 12/3/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MovieMessageCollectionViewCell: MessageCollectionViewCell {
    public static let cellReuseIdentifier = "MovieMessageCollectionViewCell"
    public static let xibFileName = "MovieMessageCollectionViewCell"
    public static let rawHeight:CGFloat = 280
    
    @IBOutlet weak var movieImageView: UIImageView!
    
    var imageRequest: URLRequest?
    var movieModel: MoviePayload?
    
    override var message: Message? {
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
