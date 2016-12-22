//
//  LZUser.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 12/17/16.
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
import Firebase

struct LZUser {
    var email: String?
    var id: String?
    var name: String?
    var photoUrl: String?
    
    public init(withFIRUser firUser: FIRUser?) {
        if let currentUser = firUser {
            email = currentUser.email
            id = currentUser.uid
            name = currentUser.displayName
            photoUrl = currentUser.photoURL?.absoluteString
        }
    }
    
    var dictionary: [String: Any] {
        var dictionary: [String : Any]  = [String: Any]()
        dictionary["email"] = email
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["photoUrl"] = photoUrl
        
        return dictionary;
    }
}
