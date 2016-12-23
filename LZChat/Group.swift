//
//  Group.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 11/23/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//  
//  Sample 
/*
{
    "id" : "-KWYv_n0af9nONROrfou",
    "lmSnippet" : "how to do",
    "title" : "Kevin PatelYqa phonereg",
    "ts" : 1479784792596,
    "usersImgs" : {
        "8j0804sBAXOnaW0AYI6vPRpfSaI2" : "https://lh4.googleusercontent.com/-6v5FaHf_KOc/AAAAAAAAAAI/AAAAAAAAAAA/AKTaeK8xIk_DrmSpOgbk-P7pCYgGsbZHow/s96-c/photo.jpg",
        "pvJwcq9LJ0Ww90Zab0Q081uBfdp1" : "https://lh6.googleusercontent.com/-cxMARBNR46g/AAAAAAAAAAI/AAAAAAAAALw/YJIFmViOKwE/s96-c/photo.jpg"
    }
}*/

import Foundation
import FirebaseDatabase

struct Group {
    var id: String?
    var lmSnippet: String?
    var title: String?
    var ts: Double?
    var usersImgs: [String:String]?
    
    var groupImageURL : URL? {
        var returnURL: URL? = nil
        if let currentUser = FirebaseUtils.sharedInstance.authUser,
            let usersImgs = usersImgs{
            for (uid, imageURLString) in usersImgs {
                if uid != currentUser.uid {
                    returnURL = URL(string: imageURLString)
                }
            }
        }
        return returnURL
    }
    
    public init(snapshot: FIRDataSnapshot) {
        let groupDictionary = snapshot.value as! Dictionary<String, AnyObject>
        id = groupDictionary["id"] as? String
        lmSnippet = groupDictionary["lmSnippet"] as? String
        title = groupDictionary["title"] as? String
        usersImgs = groupDictionary["usersImgs"] as? [String: String]
        ts = groupDictionary["ts"] as? Double
    }
}
