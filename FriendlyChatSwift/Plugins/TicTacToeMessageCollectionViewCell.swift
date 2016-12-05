//
//  TicTacToeMessageCollectionViewCell.swift
//  FriendlyChatSwift
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
    
    var tiles:[UILabel]?
    var tictactoeModel: TicTacToePayload?
    
    override var message: Message? {
        didSet {
            tictactoeModel = message?.parsedPayload as? TicTacToePayload
            if let tictactoeModel = tictactoeModel {
                for move in tictactoeModel.moves! {
                    let moveTile = tiles?[move.position!]
                    moveTile?.text = move.move?.symbol()
                }
            }
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        let tile =  recognizer.view as? UILabel
        tile?.text = MoveType.cross.symbol()
        print ("KEVINDEBUG I am touched \(self.message?.payLoad)")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tiles = [tile0, tile1, tile2, tile3, tile4, tile5, tile6, tile7, tile8]
        for tile in tiles! {
            gridView.layer.cornerRadius = 15.0
            gridView.clipsToBounds = true
            tile.text = ""
            let tapGr = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
            tile.addGestureRecognizer(tapGr)
        }
    }

}
