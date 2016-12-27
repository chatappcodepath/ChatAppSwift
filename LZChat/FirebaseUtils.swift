//
//  FirebaseUtils.swift
//  LZChat
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
        USERS = "users",
        USERSNAME = "name"
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
    
    public func listAllUsers(completion:@escaping (([LZUser]) -> Void)) {
        
        let ref = FIRDatabase.database().reference()
        let childRef = ref.child(DBPaths.USERS.rawValue)
        
        childRef.observeSingleEvent(of: .value, with:{ (usersSnapShot) in
            // got the usersSnapShot
            let users = LZUser.users(withSnapShot: usersSnapShot)
            completion(users)
        })
    }
    
    public func addNewUser() {
        let lzUser = LZUser(withFIRUser: authUser)
        let ref = FIRDatabase.database().reference()
        if let uid = lzUser.id , let refreshToken = FIRInstanceID.instanceID().token() {
            ref.child("users").child(uid).setValue(lzUser.dictionary)
            ref.child("pushTokens").child(uid).child(refreshToken).setValue("iOS")
        }
    }
    
    public func removeCurrentUser() {
        let ref = FIRDatabase.database().reference()
        if let uid = authUser?.uid, let refreshToken = FIRInstanceID.instanceID().token() {
            ref.child("pushTokens").child(uid).child(refreshToken).removeValue()
        }
    }
    
    public func groupMessageRefForGroup(group: Group) -> FIRDatabaseReference {
        let ref = FIRDatabase.database().reference()
        return ref.child(DBPaths.MESSAGES_FOR_GROUP.rawValue).child(group.id!)
    }

    public func updateMessage(in group: Group, messageToSend: Message) -> Void {
        guard let mid = messageToSend.mid else {
            return
        }
        
        let messageRef = groupMessageRefForGroup(group: group).child(mid)
        messageRef.setValue(messageToSend.messageDictionary)
        
        updateGroupAndNotifications(in: group, messageToSend: messageToSend)
    }
    
    public func createNewGroup(withUsers users:[LZUser]) -> Group {
        let groupRef = FIRDatabase.database().reference().child(DBPaths.GROUPS.rawValue)
        let newGroupRef = groupRef.childByAutoId()
        let newGroup = Group(withUsers: users, id: newGroupRef.key)
        
        newGroupRef.setValue(newGroup.dictionary)
        
        // add to GroupsForUSers
        let groupsForUsersRef = FIRDatabase.database().reference().child(DBPaths.GROUPS_FOR_USER.rawValue)
        
        for user in users {
            if let userID = user.id,
               let gid = newGroup.id {
                let userRefNode = groupsForUsersRef.child(userID).child(gid)
                userRefNode.setValue(true)
            }
        }
        return newGroup
    }
    
    public func sendMessage(in group: Group, messageToSend: Message) -> Void {
        let messageRef = groupMessageRefForGroup(group: group)
        let newChild = messageRef.childByAutoId()
        messageToSend.mid = newChild.key
        newChild.setValue(messageToSend.messageDictionary)
        
        updateGroupAndNotifications(in: group, messageToSend: messageToSend)
    }
    
    private func updateGroupAndNotifications(in group: Group, messageToSend: Message) -> Void {
        let ref = FIRDatabase.database().reference()

        let groupReference = ref.child(DBPaths.GROUPS.rawValue).child(group.id!)
        let notificationReference = ref.child(DBPaths.NOTIFICATION_REQUEST_NODE.rawValue)
        groupReference.child("lmSnippet").setValue(messageToSend.payLoad);
        groupReference.child("ts").setValue(messageToSend.tsMilliSec);
        groupReference.child("messageType").setValue(messageToSend.msgType?.rawValue);
        notificationReference.childByAutoId().setValue(PushNotification.newPushNotificationFrom(message: messageToSend, group: group).pushNotifDictionary)
    }
}


