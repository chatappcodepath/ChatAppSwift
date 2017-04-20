//
//  ImageFetchOperation.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 12/22/16.
//
//  License
//  Copyright (c) 2017 chatappcodepath
//  Released under an MIT license: http://opensource.org/licenses/MIT
//
//

import Foundation

class ImageFetchOperation: ConcurrentOperation {
    
    private let url: URL
    private let completion: ((UIImage?) -> ())?
    var loadedImage: UIImage?
    
    init(url: URL, completion: ((UIImage?) -> ())? = nil) {
        self.url = url
        self.completion = completion
        super.init()
    }
    
    override func main() {
        let urlSession = URLSession.shared.dataTask(with: self.url) { (data, urlResponse, error) in
            self.loadedImage = UIImage(data: data!)
            self.completion?(self.loadedImage)
            self.state = .Finished
        }
        urlSession.resume()
    }
}

extension ImageFetchOperation {
    
}
