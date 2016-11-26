//
//  MovieViewController.swift
//  FriendlyChatSwift
//
//  Created by Harshit Mapara on 11/25/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit
import AFNetworking

class MovieViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var movieCollectionView: UICollectionView!
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            print("Getting count ---------------------->  \(movies.count)")
            return movies.count
        }
        return 0
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionCell.reuseID, for: indexPath as IndexPath) as! MovieCollectionCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        print("Title ---------------------->  \(title)")
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl:URL! = URL(string: baseUrl + posterPath)
            cell.moveThumbnailView.setImageWith(imageUrl!)
        }
        
        cell.backgroundColor = UIColor.cyan
        
        return cell
    }

    func performNetworkRequest() {
        
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
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            
            if ((error) != nil) {
                print("There was a network error")
                return
            }
            
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    NSLog("response: \(responseDictionary)")
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    print("Moive count ############################-->  \(self.movies!.count)")
                    self.movieCollectionView.reloadData()
                }
            } else {
                print("There was an error")
            }
        });
        task.resume()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
