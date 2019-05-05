//
//  LoginViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MBProgressHUD
import LocalAuthentication
import Security

/// LoginViewController -> SignupViewController
let SIGNUP_SEGUE_IDENTIFIER = "SignupSegue"
/// LoginViewController -> TabBarViewController
let TAB_BAR_VIEW_CONTROLLER_NAME = "mainTabBarViewController"
/// Key for accessing lastAccessedUsername from UserDefaults
let USERNAME_KEY = "lastAccessedUsername"

/// The view controller to handle logging in to the app.
class LoginViewController: UIViewController {
    // MARK: - Properties
    /// Username of last saved credential
    fileprivate var lastAccessedUsername:String? {
        return UserDefaults.standard.object(forKey: USERNAME_KEY) as? String
    }
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!

    // MARK: - Lifecycle
    /// Set the properties for text fields
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.clearButtonMode = UITextField.ViewMode.always
        passwordTextField.clearButtonMode = UITextField.ViewMode.always
    }

    /// Check if credentials were saved
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // If user currently logged in
        if UsersDatabase.currentUser != nil {
            // If biometric authentication enabled
            if Util.biometricEnabled {
                // Require successful authentication
                authenticateUserUsingBiometrics()
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.switchViewControllers()
            }
        } else {
            checkRememberedCredentials()
        }
    }

    // MARK: - Actions
    /// Segue to the view for the user to create an account
    @IBAction func signupTouchUp(_ sender: Any) {
        performSegue(withIdentifier: SIGNUP_SEGUE_IDENTIFIER, sender: nil)
    }

    /// Handle user request to login.
    /// If request is valid, log the user in and segue to show the user's home
    /// Officials, otherwise prompt the user to fix login errors.
    @IBAction func loginTouchUp(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!

        // Show the loading animation
        let hud = LoadingHUD(self.view)
        self.view.endEditing(true)
        
        // Log the user in
        UsersDatabase.shared.loginUser(withEmail: email,
                                       password: password)
        {(uid, error) in
            // Stop the loading animation
            hud.end()
            if let error = error {
                self.alert(title: "Error", message: error.localizedDescription)
            } else {
                self.loginSucceeded()
            }
        }
    }

    /// If rememberMeSwitch turned off, remove saved credentials from memory
    @IBAction func rememberMeValueChanged(_ sender: Any) {
        Util.rememberMeEnabled = rememberMeSwitch.isOn
        if !Util.rememberMeEnabled {
            clearRememberedCredentials()
        }
    }

    /// Stop editing when the user touches outside of the text fields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    /// If the login succeeds segue to the entry point of the app
    private func loginSucceeded() {
        // Load the home Officials
        AppState.setup()

        // Segue to the tab bar view controller
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarViewController = storyBoard.instantiateViewController(
            withIdentifier: TAB_BAR_VIEW_CONTROLLER_NAME)
        if let appDel = UIApplication.shared.delegate as? AppDelegate {
            appDel.window?.rootViewController = tabBarViewController
            navigationController?.popToRootViewController(animated: false)
        }
    }

    // MARK: - Saved Credentials
    /// Checks if Remember Me was previously activated and activates it if so.
    //  Then checks if user credentials were saved and fills them if appropriate
    func checkRememberedCredentials() {
        // Set Remember Me Switch
        rememberMeSwitch.isOn = Util.rememberMeEnabled
        if Util.rememberMeEnabled {
            // Check that a username was saved
            guard let username = lastAccessedUsername else { return }

            // Set username field
            emailTextField.text = username
        }
    }

    /// Clears any saved credentials from UserDefaults
    fileprivate func clearRememberedCredentials() {
        // Remove saved username from UserDefaults
        UserDefaults.standard.removeObject(forKey: USERNAME_KEY)
    }

    // MARK: - Biometrics Authentication
    /// Uses biometrics to authenticate user
    fileprivate func authenticateUserUsingBiometrics() {
        let context = LAContext()
        context.localizedCancelTitle = "Enter Username/Password"
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            self.evaluateBiometricsAuthenticity(context: context)
        }
    }

    /// Executes biometric authentication and handles success or failure
    func evaluateBiometricsAuthenticity(context: LAContext) {
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "Log in to your account") { (authSuccessful, authError) in
            if authSuccessful {
                // Continue to logged in
                DispatchQueue.main.async {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.switchViewControllers()
                }
            } else {
                UsersDatabase.shared.logoutUser(completion: { (error) in })
                self.rememberMeSwitch.isOn = Util.rememberMeEnabled
                if let error = authError as? LAError {
                    self.showError(error: error)
                }
            }
        }
    }

    /// Show error message for the given LocalAuthentication Error
    func showError(error: LAError) {
        var message: String = ""
        switch error.code {
        case LAError.authenticationFailed:
            message = "Authentication was not successful because the user failed to provide valid credentials. Please enter password to login."
            break
        case LAError.userCancel:
            message = "Authentication was canceled by the user"
            return
        case LAError.userFallback:
            message = "Authentication was canceled because the user tapped the fallback button"
            break
        case LAError.biometryNotEnrolled:
            message = "Authentication could not start because Touch ID has no enrolled fingers."
            break
        case LAError.passcodeNotSet:
            message = "Passcode is not set on the device."
            break
        case LAError.systemCancel:
            message = "Authentication was canceled by system"
            break
        default:
            message = error.localizedDescription
            break
        }
        alert(title: "Error", message: message)
    }
}
