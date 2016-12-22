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
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        registerForNotifications(application: application)
        
        GIDSignIn.sharedInstance().signInSilently()
        
        if let currentUser = GIDSignIn.sharedInstance().currentUser {
            signInWithCurrentUser(user: currentUser)
        } else {
            window?.rootViewController = LoginViewController();
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
            
            FirebaseUtils.sharedInstance.addNewUser()
            let groupsVC = UserGroupsViewController()
            let nvc = UINavigationController(rootViewController: groupsVC)
            nvc.navigationBar.isTranslucent = false
            
            strongSelf.window?.rootViewController = nvc;
            
            if let userName = user?.email {
                print("Signed in with user " + userName);
            }
        }
    }
}

extension AppDelegate: GIDSignInDelegate {
    
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
    
    func signOut() {
        FirebaseUtils.sharedInstance.removeCurrentUser()
        try! FIRAuth.auth()?.signOut()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        AppState.sharedInstance.signedIn = false
        window?.rootViewController = LoginViewController()
    }
    
}

extension AppDelegate : UNUserNotificationCenterDelegate, FIRMessagingDelegate {
    func registerForNotifications(application:UIApplication) {
        NotificationCenter.default.addObserver(self, selector: #selector(tokenRefreshNotification(_:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (isGranted, error) in
                if (isGranted) {
                    print("Kevin User Granted permission")
                }
                UNUserNotificationCenter.current().delegate = self
                FIRMessaging.messaging().remoteMessageDelegate = self
            })
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let _ = FIRInstanceID.instanceID().token() {
            FirebaseUtils.sharedInstance.addNewUser()
        }
    }
    
    // Needed only for debugging
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        
        print("Kevin device token is \(token) ")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Kevin got the remoteNotification \(userInfo)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Kevin got the remoteNotification with fetchCompletionHandler \(userInfo)")
        completionHandler(.newData)
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("userNotificationCenter did receive response")
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Kevin userNotificationCenter will present notification")
        completionHandler(.alert)
    }
    
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("Kevin got the remote message from firebase for iOS-10")
    }
    
}
