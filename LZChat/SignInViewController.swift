//
//
//  License
//  Copyright (c) 2017 chatappcodepath
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

import Firebase

@objc(SignInViewController)
class SignInViewController: UIViewController, GIDSignInUIDelegate {

  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var googleSigninButton: GIDSignInButton!


  override func viewDidAppear(_ animated: Bool) {
    if let user = FIRAuth.auth()?.currentUser {
        self.signedIn(user)
    }
  }

    override func viewDidLoad() {
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
  @IBAction func didTapSignIn(_ sender: AnyObject) {
    // Sign In with credentials.
    guard let email = emailField.text, let password = passwordField.text else { return }
    FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
        if let error = error {
            print(error.localizedDescription)
            return
        }
        self.signedIn(user!)
    }
  }

  @IBAction func didTapSignUp(_ sender: AnyObject) {
    guard let email = emailField.text, let password = passwordField.text else { return }
    FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
        if let error = error {
            print(error.localizedDescription)
            return
        }
        self.setDisplayName(user!)
    }
  }

  func setDisplayName(_ user: FIRUser?) {
    guard let user = user else {
        return;
    }
    
    let changeRequest = user.profileChangeRequest()
    changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
    changeRequest.commitChanges(){ (error) in
        if let error = error {
            print(error.localizedDescription)
            return
        }
        self.signedIn(FIRAuth.auth()?.currentUser)
    }
  }

  @IBAction func didRequestPasswordReset(_ sender: AnyObject) {
    let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: .alert)
    let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
        let userInput = prompt.textFields![0].text
        if (userInput!.isEmpty) {
            return
        }
        FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    prompt.addTextField(configurationHandler: nil)
    prompt.addAction(okAction)
    present(prompt, animated: true, completion: nil);
  }

  public func signedIn(_ user: FIRUser?) {
    MeasurementHelper.sendLoginEvent()
    
    AppState.sharedInstance.displayName = user?.displayName ?? user?.email
    AppState.sharedInstance.photoURL = user?.photoURL
    AppState.sharedInstance.signedIn = true
    let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.SignedIn)
    NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
    performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: nil)
  }

}
