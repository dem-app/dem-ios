//
//  AppDelegate.swift
//  Dem
//
//  Created by Vishnu Prem on 29/06/22.
//

import UIKit
import IQKeyboardManagerSwift
//import AppAuth
//import GTMAppAuth
import GoogleSignIn
import UserNotifications
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    

//    let authorizationEndpoint = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
//    let tokenEndpoint = URL(string: "https://www.googleapis.com/oauth2/v4/token")!
//    let clientID = "499399450812-oeq06uhmqp5k9ck4vqi781m7j1a0gur7.apps.googleusercontent.com.apps.googleusercontent.com"
//    let kRedirectURI = "com.googleusercontent.apps499399450812-oeq06uhmqp5k9ck4vqi781m7j1a0gur7.apps.googleusercontent.com:/oauthredirect"

//    var currentAuthorizationFlow: OIDExternalUserAgentSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
              // Show the app's signed-out state.
            } else {
              // Show the app's signed-in state.
            }
          }
        return true
    }
    
    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      var handled: Bool

      handled = GIDSignIn.sharedInstance.handle(url)
      if handled {
        return true
      }

      // Handle other custom URL types.

      // If not handled by this app, return false.
      return false
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

