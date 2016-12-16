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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions
      launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    FIRApp.configure()
//    NotificationCenter.default.addObserver(self, selector: #selector(tokenRefreshNotification(_:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)

    GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self
    window = UIWindow.init(frame: UIScreen.main.bounds)
    let rootVC = LoginViewController()
    
    registerForNotifications(application: application)
    
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

extension AppDelegate {
    func registerForNotifications(application:UIApplication) {
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (isGranted, error) in
                if (isGranted) {
                    print("Kevin User Granted permission")
                }
            })
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        var token = String(data: deviceToken.base64EncodedData(), encoding: .utf8)?.trimmingCharacters(in: CharacterSet.whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
//        print("Kevin got the device Token \(token)");
        
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        
        print(token)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Kevin got the remoteNotification \(userInfo)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Kevin got the remoteNotification with fetchCompletionHandler \(userInfo)")
        completionHandler(.newData)
    }
    
}

/*
// All notifications related stuff
extension AppDelegate {
    func registerForRemoteNotifications(_ application:UIApplication) {
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            //            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Print full message.
        print(userInfo)
    }
}
*/
