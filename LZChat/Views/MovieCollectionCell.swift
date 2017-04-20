//
//  MovieCollectionCell.swift
//  LZChat
//
//  Created by Harshit Mapara on 11/26/16.
//
//  License
//  Copyright (c) 2017 chatappcodepath
//  Released under an MIT license: http://opensource.org/licenses/MIT
//
//

import UIKit

class MovieCollectionCell: UICollectionViewCell {
    public static let reuseID = "MovieCollectionCellReuseId"

    @IBOutlet weak var moveThumbnailView: UIImageView!
        
    public var movie: MoviePayload? {
        didSet {
            if let posterPath = movie?.poster_path {
                let baseUrl = "http://image.tmdb.org/t/p/w500"
                let imageUrl:URL! = URL(string: baseUrl + posterPath)
                //cell.posterImageView.setImageWith(imageUrl!)
                let imageRequest = URLRequest(url: imageUrl)
                
                self.moveThumbnailView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) in
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        self.moveThumbnailView.alpha = 0.0
                        self.moveThumbnailView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.moveThumbnailView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        self.moveThumbnailView.image = image
                    }
                    }, failure: { (imageRequest, iresponse, error) in
                        print("image fetch error \(error.localizedDescription)")
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
