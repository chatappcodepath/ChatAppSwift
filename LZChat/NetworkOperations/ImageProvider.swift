//
//  ImageProvider.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 12/22/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import Foundation

class ImageProvider {
    
    private let operationQueue = OperationQueue()
    let imageURL: URL
    
    init(withImageURL imageURL:URL, completion: @escaping (UIImage?) -> ()) {
        self.imageURL = imageURL
        
        let imageFetchOperation = ImageFetchOperation(url: self.imageURL) { (fetchedImage) in
            completion(fetchedImage)
        }
        
        operationQueue.addOperations([imageFetchOperation], waitUntilFinished: false)
    }
    
    func cancel() {
        operationQueue.cancelAllOperations()
    }
}
