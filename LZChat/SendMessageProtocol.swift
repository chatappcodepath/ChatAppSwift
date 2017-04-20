//
//  PluginsDelegate.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 12/6/16.
//
//  License
//  Copyright (c) 2017 chatappcodepath
//  Released under an MIT license: http://opensource.org/licenses/MIT
//
//

import Foundation

protocol SendMessageProtocol {
    func sendMessage(_ message: Message)
    func updateMessage(_ message: Message)
}
