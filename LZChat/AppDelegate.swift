//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions
      launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    FIRApp.configure()
    GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self
    window = UIWindow.init(frame: UIScreen.main.bounds)
    let rootVC = LoginViewController()
    
    if let currentUser = GIDSignIn.sharedInstance().currentUser {
        signInWithCurrentUser(user: currentUser)
    } else {
        window?.rootViewController = rootVC;
        window?.makeKeyAndVisible()
    }
    return true
  }
    
    func signInWithCurrentUser(user: GIDGoogleUser) {
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential){ [weak self] (user, err) in
            guard let strongSelf = self else { return }
            
            let groupsVC = UserGroupsViewController()
            let nvc = UINavigationController(rootViewController: groupsVC)
            nvc.navigationBar.isTranslucent = false
            
            strongSelf.window?.rootViewController = nvc;
            
            if let userName = user?.email {
                print("Signed in with user " + userName);
            }
        }
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        if let error = error {
            print("Error in Google Signin " + error.localizedDescription);
            return
        }
        signInWithCurrentUser(user: user)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if #available(iOS 9.0, *) {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        } else {
            return false
        }
    }
    
    // Finished disconnecting |user| from the app successfully if |error| is |nil|.
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        try! FIRAuth.auth()!.signOut()
    }
}
