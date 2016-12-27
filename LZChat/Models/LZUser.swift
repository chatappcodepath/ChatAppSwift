//
//  LZUser.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 12/17/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//
//  Sample
/*
 "kI9OZDu4SFRktlrZu6LJZrfvXOv1" : {
 "email" : "yqaphonereg01@gmail.com",
 "id" : "kI9OZDu4SFRktlrZu6LJZrfvXOv1",
 "name" : "Yqa phonereg",
 "photoUrl" : "https://lh4.googleusercontent.com/-6v5FaHf_KOc/AAAAAAAAAAI/AAAAAAAAAAA/AKTaeK8xIk_DrmSpOgbk-P7pCYgGsbZHow/s96-c/photo.jpg"
 }
 */

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
    
    public static func users(withSnapShot snapShot:FIRDataSnapshot) -> [LZUser] {
        var retUsers = [LZUser]()
        if let usersDict = snapShot.value as? [String: Any] {
            for dictionary in usersDict.values {
                if let dictionary = dictionary as? [String: Any] {
                    retUsers.append(LZUser(withDictionary: dictionary))
                }
            }
        }
        return retUsers
    }
    
    public init(withDictionary dictionary:[String: Any]) {
        self.dictionary = dictionary
    }
    
    var dictionary: [String: Any] {
        get {
            var dictionary: [String : Any]  = [String: Any]()
            dictionary["email"] = email
            dictionary["id"] = id
            dictionary["name"] = name
            dictionary["photoUrl"] = photoUrl
            
            return dictionary;
        }
        set {
            self.email = newValue["email"] as? String
            self.id = newValue["id"] as? String
            self.name = newValue["name"] as? String
            self.photoUrl = newValue["photoUrl"] as? String
        }
    }
}

extension LZUser: Equatable {
    public static func ==(lhs: LZUser, rhs: LZUser) -> Bool {
        return lhs.id == rhs.id
    }
}







