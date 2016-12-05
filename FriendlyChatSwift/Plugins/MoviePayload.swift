//
//  File.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 12/4/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//
/* Sample Data
 {
 "backdrop_path": "/tFI8VLMgSTTU38i8TIsklfqS9Nl.jpg",
 "id": "284052",
 "overview": "After his career is destroyed, a brilliant but arrogant surgeon gets a new lease on life when a sorcerer takes him under his wing and trains him to defend the world against evil.",
 "poster_path": "/xfWac8MTYDxujaxgPVcRD9yZaul.jpg",
 "title": "Doctor Strange",
 "trailerURL": "HSzx-zryEgM",
 "vote_average": 6.6
 }
 */

import Foundation

struct MoviePayload {
    var backdrop_path:String?
    var id:String?
    var overview:String?
    var poster_path:String?
    var title:String?
    var trailerURL:String?
    var vote_average:String?
    
    init(jsonPayload:String) {
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: jsonPayload.data(using:.utf8)!, options: .allowFragments) as? [String: Any] {
                backdrop_path = jsonResult["backdrop_path"] as? String
                id = jsonResult["id"] as? String
                overview = jsonResult["overview"] as? String
                poster_path = jsonResult["poster_path"] as? String
                title = jsonResult["title"] as? String
                trailerURL = jsonResult["trailerURL"] as? String
                vote_average = jsonResult["vote_average"] as? String
            }
        } catch {
            print("Error processing JSON");
        }
    }
    
}
