//
//  TicTacToePayload.swift
//  LZChat
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
    var displayString: String {
        if self == .cross {
            return "X"
        }
        return "O"
    }
}

enum TileState: String {
    case X
    case O
    case Empty
    func symbol() -> String {
        switch self {
        case .X:
            return "✗"
        case .O:
            return "○"
        default:
            return ""
        }
    }
}

enum GameState: String {
    case Playing
    case Win
    case Lose
    case Draw
    var description: String? {
        switch self {
        case .Win:
            return "!!You Won!! ☺"
        case .Lose:
            return "You Lost ☹"
        case .Draw:
            return "Its a Draw"
        default:
            return nil
        }
    }
}

struct Move {
    private(set) var move: MoveType?
    private(set) var sid: String?
    private(set) var position: Int?
    
    var dictionary: [String: Any]? {
        if let move = self.move, let sid = self.sid, let position = self.position {
            return ["move": move.rawValue, "sid": sid, "position": position]
        }
        return nil
    }
    
    init(jsonDictionary: [String: Any?]) {
        if let rawValue = jsonDictionary["move"] as? String {
            move = MoveType(rawValue: rawValue)
        }
        sid = jsonDictionary["sid"] as? String
        position = jsonDictionary["position"] as? Int
    }
    
    init(move: MoveType, sid: String, position: Int) {
        self.move = move
        self.sid = sid
        self.position = position
    }
}

struct TicTacToePayload {
    private var moves: [Move]?
    private var xSids: Set<String>
    private var oSids: Set<String>
    private(set) var currentTileStates: [TileState]
    static var newGamePayload = "[]"
    var snippet: String? {
        if let moves = moves {
            return "TicTacToe: " + moves.map({ (move) -> String in
                return "\(move.move!.displayString):\(move.position!)"
            }).joined(separator: ", ")
        }
        
        return "TicTacToe"
    }
    
    init(jsonPayload:String) {
        moves = [Move]()
        xSids = Set<String>()
        oSids = Set<String>()
        currentTileStates = [TileState]()
        
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: jsonPayload.data(using:.utf8)!, options: .allowFragments) as? [[String: Any]] {
                print("KevinDebug I am testing \(jsonResult)");
                for rawMove in jsonResult {
                    let move = Move(jsonDictionary: rawMove)
                    moves?.append(move)
                }
                populateCurrentTileStates()
                populateSids()
            }
        } catch {
            print("Error processing JSON");
        }
    }
    
    mutating private func populateCurrentTileStates() {
        guard let moves = moves else {
            return
        }
        
        currentTileStates = [.Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty, .Empty]
        for move in moves {
            if let position = move.position {
                currentTileStates[position] = move.move == .o ? .O : .X;
            }
        }
    }
    
    mutating private func populateSids() {
        guard let moves = moves else {
            return
        }
        for move in moves {
            if let sid = move.sid {
                if (move.move == .cross) {
                    xSids.insert(sid)
                } else {
                    oSids.insert(sid)
                }
            }
        }
    }
    
    private var winningTileState : TileState? {
        let cs = currentTileStates
        
        if (cs[0] == cs[1] && cs[1] == cs[2] && cs[0] != .Empty) {
            return cs[0];
        }
        
        if (cs[3] == cs[4] && cs[4] == cs[5] && cs[3] != .Empty) {
            return cs[3];
        }
        
        if (cs[6] == cs[7] && cs[7] == cs[8] && cs[6] != .Empty) {
            return cs[6];
        }
        
        if (cs[0] == cs[3] && cs[3] == cs[6] && cs[0] != .Empty) {
            return cs[0];
        }
        
        if (cs[1] == cs[4] && cs[4] == cs[7] && cs[1] != .Empty) {
            return cs[1];
        }
        
        if (cs[2] == cs[5] && cs[5] == cs[8] && cs[2] != .Empty) {
            return cs[2];
        }
        
        if (cs[0] == cs[4] && cs[4] == cs[8] && cs[0] != .Empty) {
            return cs[0];
        }
        
        if (cs[2] == cs[4] && cs[4] == cs[6] && cs[2] != .Empty) {
            return cs[2];
        }
        
        return nil
    }
    
    func getGameResult(sid: String) -> GameState {
        guard let winningTileState = winningTileState else {
            for tileState in currentTileStates {
                if tileState == .Empty {
                    return .Playing
                }
            }
            return .Draw
        }
        
        if (winningTileState == .X && xSids.contains(sid)) {
            return .Win
        }
        
        if (winningTileState == .O && oSids.contains(sid)) {
            return .Win
        }
        
        return .Lose
    }
    
    
    
    var jsonPayload:String {
        var movesDictionary = [[String: Any]]()

        guard let moves = moves else {return TicTacToePayload.newGamePayload}
        if moves.count == 0  {return TicTacToePayload.newGamePayload}
        
        for move in moves {
            if let moveDictionary = move.dictionary {
                movesDictionary.append(moveDictionary)
            }
        }
        if let data = try? JSONSerialization.data(withJSONObject: movesDictionary) {
            if let retString = String(data: data, encoding: .utf8) {
                return retString
            }
        }
        
        return TicTacToePayload.newGamePayload
    }
    
    mutating func payloadWithAutoPlay(forSid sid:String) -> String? {
        for i in 0..<currentTileStates.count {
            if (currentTileStates[i] == .Empty) {
                return payloadAfterTouchingTile(atPosition: i, sid: sid)
            }
        }
        return nil
    }
    
    mutating func payloadAfterTouchingTile(atPosition position:Int, sid: String) -> String? {
        if (currentTileStates[position] != .Empty) {
            return nil
        }
        
        if getGameResult(sid: sid) != .Playing {
            return nil
        }
        
        var nextMoveType:MoveType = .cross
        if let moves = moves {
            if (moves.count > 0) {
                nextMoveType = moves.last?.move == .o ? .cross : .o
            }
        }
        
        let impermissibleSids = nextMoveType == .cross ? oSids : xSids
        
        if (impermissibleSids.contains(sid)) {
            return nil
        }
        
        moves?.append(Move(move: nextMoveType, sid: sid, position: position))
        currentTileStates[position] = nextMoveType == .o ? .O : .X
        
        if (nextMoveType == .o) {
            oSids.insert(sid)
        } else {
            xSids.insert(sid)
        }
        
        return jsonPayload
    }
}
