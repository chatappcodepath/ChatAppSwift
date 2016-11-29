//
//  Message.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 11/24/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//
// Sample Data 
/* {
"isBotMessage" : false,
"msgType" : "Text",
"name" : "Yqa phonereg",
"payLoad" : "hello sir how are you ?",
"photoUrl" : "https://lh4.googleusercontent.com/-6v5FaHf_KOc/AAAAAAAAAAI/AAAAAAAAAAA/AKTaeK8xIk_DrmSpOgbk-P7pCYgGsbZHow/s96-c/photo.jpg",
"sid" : "8j0804sBAXOnaW0AYI6vPRpfSaI2",
"ts" : 1479760139967
}
 */

import Foundation
import FirebaseDatabase
import JSQMessagesViewController

class Message: NSObject {
    var isBotMessage : Bool?
    var msgType : String?
    var name : String?
    var mid : String?
    var payLoad : String?
    var photoUrl : String?
    var sid : String?
    var ts: TimeInterval?
    var tsMilliSec: UInt? {
        get {
            return UInt(ts! * 1000)
        }
        set(newTsMilliSec) {
            ts = TimeInterval(Float(newTsMilliSec!/1000))
        }
    }
    

    public init(snapshot: FIRDataSnapshot) {
        super.init()
        let messageDictionary = snapshot.value as! Dictionary<String, AnyObject>
        isBotMessage = messageDictionary["isBotMessage"] as? Bool
        msgType = messageDictionary["msgType"] as? String
        name = messageDictionary["name"] as? String
        mid = messageDictionary["mid"] as? String
        payLoad = messageDictionary["payLoad"] as? String
        photoUrl = messageDictionary["photoUrl"] as? String
        sid = messageDictionary["sid"] as? String
        tsMilliSec = messageDictionary["ts"] as? UInt
    }
    
    override init() {
        super.init()
    }
    
    var messageDictionary: [String: Any] {
        var messageDictionary: [String : Any]  = [String: Any]()
        messageDictionary["isBotMessage"] = isBotMessage
        messageDictionary["msgType"] = msgType
        messageDictionary["name"] = name
        messageDictionary["mid"] = mid
        messageDictionary["payLoad"] = payLoad
        messageDictionary["photoUrl"] = photoUrl
        messageDictionary["sid"] = sid
        messageDictionary["ts"] = tsMilliSec
        
        return messageDictionary;
    }
    
    public static func newTextMessageWith(content: String) -> Message {
        let newMesssage = Message();
        let currentUser = FirebaseUtils.sharedInstance.authUser;
        
        newMesssage.isBotMessage = false
        newMesssage.msgType = "Text"
        newMesssage.name = currentUser?.displayName
        newMesssage.payLoad = content
        newMesssage.photoUrl = currentUser?.photoURL?.absoluteString
        newMesssage.sid = currentUser?.uid
        newMesssage.ts = Date().timeIntervalSince1970
        
        return newMesssage;
    }
}

extension Message: JSQMessageData {
    
    func senderId() -> String! {
        return self.sid
    }
    
    
    /**
     *  @return The display name for the user who sent the message.
     *
     *  @warning You must not return `nil` from this method.
     */
    public func senderDisplayName() -> String! {
        return self.name
    }
    
    
    /**
     *  @return The date that the message was sent.
     *
     *  @warning You must not return `nil` from this method.
     */
    public func date() -> Date! {
        return Date(timeIntervalSince1970: self.ts!);
    }
    
    
    /**
     *  This method is used to determine if the message data item contains text or media.
     *  If this method returns `YES`, an instance of `JSQMessagesViewController` will ignore
     *  the `text` method of this protocol when dequeuing a `JSQMessagesCollectionViewCell`
     *  and only call the `media` method.
     *
     *  Similarly, if this method returns `NO` then the `media` method will be ignored and
     *  and only the `text` method will be called.
     *
     *  @return A boolean value specifying whether or not this is a media message or a text message.
     *  Return `YES` if this item is a media message, and `NO` if it is a text message.
     */
    public func isMediaMessage() -> Bool {
        return false
    }
    
    
    /**
     *  @return An integer that can be used as a table address in a hash table structure.
     *
     *  @discussion This value must be unique for each message with distinct contents.
     *  This value is used to cache layout information in the collection view.
     */
    public func messageHash() -> UInt {
        return UInt(self.ts!)
    }
    
    
    /**
     *  @return The body text of the message.
     *
     *  @warning You must not return `nil` from this method.
     */
    public func text() -> String! {
        return self.payLoad
    }
    
}
