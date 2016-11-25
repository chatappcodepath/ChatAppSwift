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
        NOTIFICATION_REQUEST_NODE = "notificationRequests",
        USERS = "users"
    }
    
    static let sharedInstance = FirebaseUtils()
    
    var authUser: FIRUser? {
        return FIRAuth.auth()?.currentUser
    }
    
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
    
    public func groupMessageRefForGroup(group: Group) -> FIRDatabaseReference {
        let ref = FIRDatabase.database().reference()
        return ref.child(DBPaths.MESSAGES_FOR_GROUP.rawValue).child(group.id!)
    }

    public func sendMessage(in group: Group, messageToSend: Message) -> Void {
        let ref = FIRDatabase.database().reference()
        let messageRef = groupMessageRefForGroup(group: group)
        let groupReference = ref.child(DBPaths.GROUPS.rawValue).child(group.id!)
        let notificationReference = ref.child(DBPaths.NOTIFICATION_REQUEST_NODE.rawValue)
        messageRef.childByAutoId().setValue(messageToSend.messageDictionary)
        groupReference.child("lmSnippet").setValue(messageToSend.payLoad);
        groupReference.child("ts").setValue(messageToSend.tsMilliSec);
        notificationReference.childByAutoId().setValue(PushNotification.newPushNotificationFrom(message: messageToSend, group: group).pushNotifDictionary)
    }
}


