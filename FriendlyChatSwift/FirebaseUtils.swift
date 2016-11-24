//
//  FirebaseUtils.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 11/23/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import Foundation
import Firebase

class FirebaseUtils: NSObject {
    
    public enum DBPaths : String {
        case GROUPS = "groups",
        GROUPS_FOR_USER = "groupsForUser",
        MESSAGES_FOR_GROUP = "messagesForGroup",
        PUSHTOKEN = "pushTokens",
        USERS = "users"
    }
    
    static let sharedInstance = FirebaseUtils()
    
    var authUser: FIRUser? {
        return FIRAuth.auth()?.currentUser
    }
    var signedIn = false
    var displayName: String?
    var photoURL: URL?
    
    public func groupsForCurrentUser(completion:@escaping (([Group]) -> Void)) {
        
        let ref = FIRDatabase.database().reference()
        guard let uid = authUser?.uid else {
            return
        }
        let childRef = ref.child(DBPaths.GROUPS_FOR_USER.rawValue).child(uid)
        
        var groups = [Group]();
        var receivedGroupsCount = 0;
        
        childRef.observeSingleEvent(of: .value, with: { (childSnapshot) -> Void in
            let gidsDictionary = childSnapshot.value as? [String :Bool]
            if let gids = gidsDictionary?.keys {
                for gid in gids {
                    let gidRef = ref.child(DBPaths.GROUPS.rawValue).child(gid)
                    gidRef.observeSingleEvent(of: .value, with: { (groupSnapShot) in
                        receivedGroupsCount += 1;
                        groups.append(Group(snapshot: groupSnapShot))
                        if receivedGroupsCount == gids.count {
                            completion(groups)
                        }
                    })
                }
            }
        })
    }
}


