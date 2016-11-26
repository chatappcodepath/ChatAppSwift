//
//  UserGroupsMessageViewController.swift
//  FriendlyChatSwift
//
//  Created by Harshit Mapara on 11/25/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit

class UserGroupsMessageExtensionViewController: UIViewController {

    @IBOutlet weak var groupConversationView: UIView!
    @IBOutlet weak var extensionContentView: UIView!
    
    public var selectedGroup: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let groupMessagesVC = GroupMessagesViewController()
        groupMessagesVC.group = selectedGroup
        groupMessagesVC.view.bounds = groupConversationView.bounds
        groupConversationView.addSubview(groupMessagesVC.view)
        
        //Load appropriate extensionViewController (ideally on clicking something)
        let movieVC = MovieViewController()
        movieVC.view.bounds = extensionContentView.bounds
        extensionContentView.addSubview(movieVC.view)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
