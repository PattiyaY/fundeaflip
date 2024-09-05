//
//  AppDelegate.swift
//  MemeGenerator
//
//  Created by Pattiya Yiadram on 26/8/24.
//

import UIKit
import FirebaseCore
import LocalAuthentication


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        // Check if app was launched via a Quick Action
        
        authenticateUser()
        
        return true
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your account."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        print("Authenticated successfully")
                        // Continue to your app's home screen
                    } else {
                        if let error = authenticationError {
                            print("Authentication failed: \(error.localizedDescription)")
                            // Handle error (e.g., show alert, fallback to password)
                        }
                    }
                }
            }
        } else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            // Handle if biometrics are not available
        }
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

