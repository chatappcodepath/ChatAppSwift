//
//  LoginViewController.swift
//  LZChat
//
//  Created by Kevin Balvantkumar Patel on 11/22/16.
//
//  License
//  Copyright (c) 2017 chatappcodepath
//  Released under an MIT license: http://opensource.org/licenses/MIT
//
//

import UIKit

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var googleSigninButton: GIDSignInButton!
    public var hideSignInButton: Bool = true {
        didSet {
            if (self.viewIfLoaded != nil) {
                googleSigninButton.isHidden = hideSignInButton
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideSignInButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        googleSigninButton.layer.cornerRadius = 20.0
        googleSigninButton.clipsToBounds = true
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSigninButton.isHidden = hideSignInButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
