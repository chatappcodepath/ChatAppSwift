//
//  LoginViewController.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 11/22/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var googleSigninButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
