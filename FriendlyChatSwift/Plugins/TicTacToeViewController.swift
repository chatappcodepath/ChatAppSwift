//
//  TicTacToeViewController.swift
//  FriendlyChatSwift
//
//  Created by Kevin Balvantkumar Patel on 12/1/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit

class TicTacToeViewController: UIViewController {

    var sendMessageDelegate : SendMessageProtocol?
    @IBOutlet weak var newGameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newGameButton.layer.cornerRadius = 15
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startNewGame() {
        let newMessage = Message.newMessageWith(payload: TicTacToePayload.newGamePayload, messageType: .TicTacToe)
        sendMessageDelegate?.sendMessage(newMessage)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
