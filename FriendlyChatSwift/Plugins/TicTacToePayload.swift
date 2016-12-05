//
//  TicTacToePayload.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 12/4/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

/* SampleData
 [{
 "move": "x",
 "sid": "LXawM7LaqqWUrxvgMsxBF4K1ott1",
 "position": 2
 }, {
 "move": "o",
 "sid": "J0aCDIqoMRbaL6yzFY2a9bcIJXa2",
 "position": 5
 }]
 */

import Foundation
enum MoveType:String {
    case cross
    case o
    func symbol() -> String {
        switch self {
        case .cross:
            return "X"
        default:
            return "O"
        }
    }
}

struct Move {
    var move: MoveType?
    var sid: String?
    var position: Int?
    init(jsonDictionary: [String: Any?]) {
        if let rawValue = jsonDictionary["move"] as? String {
            move = MoveType(rawValue: rawValue)
        }
        sid = jsonDictionary["sid"] as? String
        position = jsonDictionary["position"] as? Int
    }
}

struct TicTacToePayload {
    var moves: [Move]?
    init(jsonPayload:String) {
        moves = [Move]()
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: jsonPayload.data(using:.utf8)!, options: .allowFragments) as? [[String: Any]] {
                print("KevinDebug I am testing \(jsonResult)");
                for rawMove in jsonResult {
                    let move = Move(jsonDictionary: rawMove)
                    moves?.append(move)
                }
            }
        } catch {
            print("Error processing JSON");
        }
    }
    
}
