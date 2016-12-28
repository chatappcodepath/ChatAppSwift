//
//  PushNotification.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 11/25/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import Foundation

class PushNotification: NSObject {
    var groupID: String?
    var payload: String?
    var senderID: String?
    var title: String?
    
    public static func newPushNotificationFrom(message: Message, group: Group) -> PushNotification {
        let pushNotif = PushNotification()
        
        pushNotif.groupID = group.id
        pushNotif.payload = message.snippet
        pushNotif.senderID = message.sid
        pushNotif.title = message.name
        
        return pushNotif;
    }
    
    var pushNotifDictionary: [String: Any] {
        var retDictionary = [String: Any]()
        retDictionary["groupID"] = groupID
        retDictionary["payload"] = payload
        retDictionary["senderID"] = senderID
        retDictionary["title"] = title
        return retDictionary
    }
}
