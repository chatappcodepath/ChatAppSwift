//
//  PluginsDelegate.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 12/6/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import Foundation

protocol SendMessageProtocol {
    func sendMessage(_ message: Message)
    func updateMessage(_ message: Message)
}
