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
    var messageType: String?
    var usersImgs: [String:String]?
    
    var groupImageURL : URL? {
        var returnURL: URL? = nil
        if let currentUser = FirebaseUtils.sharedInstance.authUser,
            let usersImgs = usersImgs {
            for (uid, imageURLString) in usersImgs {
                if returnURL == nil {
                    returnURL = URL(string: imageURLString) // fixing for selfie chat
                }
                if uid != currentUser.uid {
                    returnURL = URL(string: imageURLString)
                }
            }
        }
        return returnURL
    }
    
    var dictionary: [String: Any] {
        var dictionary: [String : Any]  = [String: Any]()
        dictionary["id"] = id
        dictionary["title"] = title
        dictionary["lmSnippet"] = lmSnippet
        dictionary["ts"] = ts
        dictionary["messageType"] = messageType
        dictionary["usersImgs"] = usersImgs
        
        return dictionary;
    }
    
    func containsOnlyUIDs(uids: [String]) -> Bool {
        let newArr = Array(uids)
        let arr = Array(usersImgs!.keys)
        return (arr.sorted().joined() == newArr.sorted().joined())
    }
    
    public init(snapshot: FIRDataSnapshot) {
        let groupDictionary = snapshot.value as! Dictionary<String, AnyObject>
        id = groupDictionary["id"] as? String
        lmSnippet = groupDictionary["lmSnippet"] as? String
        title = groupDictionary["title"] as? String
        usersImgs = groupDictionary["usersImgs"] as? [String: String]
        ts = groupDictionary["ts"] as? Double
    }
    
    public init(withUsers users:[LZUser], id: String) {
        /* create a Group with "-KX8TNimUaHT7GtcRsyT" : {
        "id" : "-KX8TNimUaHT7GtcRsyT",
        "lmSnippet" : "fgh",
        "messageType" : "Text",
        "title" : "Harshit MaparaKevin Patel",
        "ts" : 1479776013212,
        "usersImgs" : {
            "Pn4FeKRkdsO5OnWaKuHl5zIfPKm1" : "https://lh4.googleusercontent.com/-VJZWNREIAsU/AAAAAAAAAAI/AAAAAAAAAAA/AEMOYSBHFSjau-yhwcPi64ZghP8rRsLaHQ/s96-c/photo.jpg",
            "AjVfqUA4a0UciE7RhKiFr8MTEr73" : "https://lh6.googleusercontent.com/-cxMARBNR46g/AAAAAAAAAAI/AAAAAAAAALw/YJIFmViOKwE/s96-c/photo.jpg"
        }
    }*/
        self.id = id
        self.title = "Say Something break the ice!!"
        self.messageType = MessageType.Text.rawValue
        self.ts = Date().timeIntervalSince1970 * 1000
        var newTitle = "";
        var newUsersImages = [String: String]()
        
        for user in users {
            if let userName = user.name, let userID = user.id, let photoURL = user.photoUrl {
                newTitle += userName
                newUsersImages[userID] = photoURL
            }
        }
        
        self.title = newTitle
        self.usersImgs = newUsersImages
    }
}
