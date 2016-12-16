//
//  TicTacToeMessageCollectionViewCell.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 12/4/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit

class TicTacToeMessageCollectionViewCell: MessageCollectionViewCell {
    public static let cellReuseIdentifier = "TicTacToeMessageCollectionViewCell"
    public static let xibFileName = "TicTacToeMessageCollectionViewCell"
    public static let rawHeight:CGFloat = 210
    
    @IBOutlet weak var tile0: UILabel!
    @IBOutlet weak var tile1: UILabel!
    @IBOutlet weak var tile2: UILabel!
    @IBOutlet weak var tile3: UILabel!
    @IBOutlet weak var tile4: UILabel!
    @IBOutlet weak var tile5: UILabel!
    @IBOutlet weak var tile6: UILabel!
    @IBOutlet weak var tile7: UILabel!
    @IBOutlet weak var tile8: UILabel!
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var tiles:[UILabel]?
    var tictactoeModel: TicTacToePayload?
    
    override var message: Message? {
        didSet {
            tictactoeModel = message?.parsedPayload as? TicTacToePayload
            if let tictactoeModel = tictactoeModel,
               let sid = FirebaseUtils.sharedInstance.authUser?.uid {
                for i in 0..<tictactoeModel.currentTileStates.count {
                    tiles?[i].text = tictactoeModel.currentTileStates[i].symbol()
                }
                if let resultString = tictactoeModel.getGameResult(sid: sid).description {
                    resultLabel.text = resultString
                    resultLabel.isHidden = false
                } else {
                    resultLabel.isHidden = true
                }
            }
        }
    }
    
    private func positionOfTile(tile: UILabel?) -> Int? {
        for i in 0..<tiles!.count {
            if (tile == tiles?[i]) { return i }
        }
        return nil
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        let tile =  recognizer.view as? UILabel
        if let position = positionOfTile(tile: tile),
            let message = message,
            let currentUser = FirebaseUtils.sharedInstance.authUser {
            if let payload = tictactoeModel?.payloadAfterTouchingTile(atPosition: position, sid: currentUser.uid) {
                let updatedMessage = Message.updatedMessageWith(payload: payload, currentMessage: message)
                messageSendingDelegate?.updateMessage(updatedMessage)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tiles = [tile0, tile1, tile2, tile3, tile4, tile5, tile6, tile7, tile8]
        for tile in tiles! {
            gridView.layer.cornerRadius = 15.0
            gridView.clipsToBounds = true
            let tapGr = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
            tile.addGestureRecognizer(tapGr)
        }
    }

}
