//
//  MovieViewController.swift
//  LZChat
//
//  Created by Harshit Mapara on 11/25/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit
import AFNetworking

class MovieViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var movieCollectionView: UICollectionView!
    var movies: [MoviePayload]?
    var sendMessageDelegate : SendMessageProtocol?
    
    static let interCellSpacing:CGFloat = 9
    
    var sizeForItem:CGSize {
        let containerWidth = self.movieCollectionView.bounds.width
        let maxItems = floor(containerWidth / 110)
        let itemWidth = floor((containerWidth - (maxItems - 1)*MovieViewController.interCellSpacing) / maxItems)
        let itemHeight = itemWidth * 1.33
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = self.sizeForItem
        flowLayout.minimumInteritemSpacing = MovieViewController.interCellSpacing
        
        movieCollectionView.collectionViewLayout = flowLayout
        
        movieCollectionView.dataSource = self
        movieCollectionView.delegate = self
        self.movieCollectionView.register(UINib(nibName: "MovieCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: MovieCollectionCell.reuseID)

        performNetworkRequest()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForItem
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionCell.reuseID, for: indexPath as IndexPath) as! MovieCollectionCell
        cell.movie = movies![indexPath.row]        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let moviePayload = movies?[indexPath.row].payload {
            let newMessage = Message.newMessageWith(payload: moviePayload, messageType: .Movie)
            sendMessageDelegate?.sendMessage(newMessage)
        }
    }
    

    func performNetworkRequest() {
        //TODO MOVE to client file
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1.0
        
        let session = URLSession(
            configuration: sessionConfig,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: {[weak self] (dataOrNil, response, error) in
            
            guard let strongSelf = self else {return}
            
            if ((error) != nil) {
                print("There was a network error")
                return
            }
            
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any] {
                    if let jsonArray = responseDictionary["results"] as? [[String: Any]] {
                        strongSelf.movies = MoviePayload.moviesFromJSONArray(jsonArray)
                    }
                    strongSelf.movieCollectionView.reloadData()
                }
            } else {
                print("There was an error")
            }
        });
        task.resume()
    }
}
