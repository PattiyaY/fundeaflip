import UIKit
import LocalAuthentication

class SecureViewController: UIViewController {
    
    var blurEffectView: UIVisualEffectView?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBlurEffect()
        authenticateUser()
    }

    func showBlurEffect() {
        // Create a blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        // Set the frame to cover the whole screen
        blurEffectView?.frame = view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add the blur effect view to the view hierarchy
        if let blurEffectView = blurEffectView {
            view.addSubview(blurEffectView)
        }
    }

    func removeBlurEffect() {
        // Remove the blur effect view
        blurEffectView?.removeFromSuperview()
    }

    func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access secure features."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        print("Authentication was successful!")
                        // Remove the blur effect when authentication succeeds
                        self.removeBlurEffect()
                        
                        // Present the next view controller modally
                                                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                                                let memePage = storyboard.instantiateViewController(withIdentifier: "homePage") as! ViewController
                                                self.present(memePage, animated: true, completion: nil)
                    } else {
                        // Handle failure
                        if let error = authenticationError {
                            print("Authentication failed: \(error.localizedDescription)")
                        }
                        // Optionally remove the blur effect if you want to allow access after failure
                        self.removeBlurEffect()
                    }
                }
            }
        } else {
            // Handle if biometric authentication is not available
            print("Biometric authentication is not available: \(error?.localizedDescription ?? "Unknown error")")
            // Remove the blur effect if authentication is not possible
            removeBlurEffect()
        }
    }
}
