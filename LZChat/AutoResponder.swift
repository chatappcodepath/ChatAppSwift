//
//  AutoResponder.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 12/7/16.
//
//  License
//  Copyright (c) 2017 chatappcodepath
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import JavaScriptCore

class AutoResponder {
    var jsContext: JSContext
    var transformText: JSValue?
    
    static let sharedInstance = AutoResponder()
    
    private init() {
        self.jsContext = JSContext()
        
        if let rawData = FileManager.default.contents(atPath: Bundle.main.path(forResource: "eliza-min", ofType: "js")!) {
            let rawString = String(data: rawData, encoding: .utf8)
            self.jsContext.evaluateScript(rawString)
            transformText = self.jsContext.objectForKeyedSubscript("transformText")
        }
    }
    
    func sendMessageIfNeededWith(inputMessage: Message, messageSendingDelegate: SendMessageProtocol!) -> Void {
        if let currentUserSid = FirebaseUtils.sharedInstance.authUser?.uid,
            let lastSid = inputMessage.sid,
            let inputMessageType = inputMessage.msgType,
            let messagePayload = inputMessage.payLoad,
            let isBotMessage = inputMessage.isBotMessage {
            if (isBotMessage) {
                return
            }
            
            if (currentUserSid != lastSid && inputMessageType == .Text) {
                if let result = transformText?.call(withArguments: [messagePayload]).toString() {
                    let respondMessage = Message.newMessageWith(payload: result, messageType: .Text)
                    respondMessage.isBotMessage = true
                    messageSendingDelegate.sendMessage(respondMessage)
                }
            }
            
            if (inputMessageType == .TicTacToe) {
                var currentPayload = TicTacToePayload(jsonPayload: messagePayload)
                if let newPayload = currentPayload.payloadWithAutoPlay(forSid: currentUserSid) {
                    let newMessage = Message.updatedMessageWith(payload: newPayload, currentMessage: inputMessage)
                    messageSendingDelegate.updateMessage(newMessage)
                }
            }
        }
    }
}
