//
//  File.swift
//  LZChat
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
 
 {"backdrop_path":"/slpgZisYNapLoN9FWXqDOC1ExbU.jpg","id":"259693","overview":"Lorraine and Ed Warren travel to north London to help a single mother raising four children alone in a house plagued by malicious spirits.","poster_path":"/pUwdglql8cbztEink0JCgG1TY28.jpg","title":"The Conjuring 2","trailerURL":"KyA9AtUOqRM","vote_average":6.6}
 

 {
 "poster_path": "/gri0DDxsERr6B2sOR1fGLxLpSLx.jpg",
 "adult": false,
 "overview": "In 1926, Newt Scamander arrives at the Magical Congress of the United States of America with a magically expanded briefcase, which houses a number of dangerous creatures and their habitats. When the creatures escape from the briefcase, it sends the American wizarding authorities after Newt, and threatens to strain even further the state of magical and non-magical relations.",
 "release_date": "2016-11-16",
 "genre_ids": [10751, 12, 14],
 "id": 259316,
 "original_title": "Fantastic Beasts and Where to Find Them",
 "original_language": "en",
 "title": "Fantastic Beasts and Where to Find Them",
 "backdrop_path": "/6I2tPx6KIiBB4TWFiWwNUzrbxUn.jpg",
 "popularity": 46.767417,
 "vote_count": 970,
 "video": false,
 "vote_average": 7
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
    var dictionary:[String: Any]? {
        if let backdrop_path = backdrop_path,
            let id = id,
            let overview = overview,
            let poster_path = poster_path,
            let title = title,
            let trailerURL = trailerURL,
            let vote_average = vote_average {
            return ["backdrop_path": backdrop_path, "id": id, "overview": overview, "poster_path": poster_path, "title": title, "trailerURL": trailerURL, "vote_average": vote_average]
                
        }
        return nil
    }
    
    var snippet: String? {
        return self.title
    }
    
    var payload:String? {
        guard let payloadDictionary = dictionary else {
            return nil
        }
        if let data = try? JSONSerialization.data(withJSONObject: payloadDictionary) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    static func moviesFromJSONArray(_ jsonArray: [[String: Any]]) -> [MoviePayload]{
    var parsedMovies = [MoviePayload]()
        for movieDict in jsonArray {
            parsedMovies.append(MoviePayload(dictionary: movieDict))
        }
        return parsedMovies
    }
    
    init(dictionary: [String: Any]) {
        backdrop_path = dictionary["backdrop_path"] as? String
        id = "\(dictionary["id"] as! Int)"
        overview = dictionary["overview"] as? String
        poster_path = dictionary["poster_path"] as? String
        title = dictionary["title"] as? String
        vote_average = "\(dictionary["vote_average"] as! Int)"
    }
    
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
