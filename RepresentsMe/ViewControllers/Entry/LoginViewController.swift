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

/// LoginViewController -> SignupViewController
let SIGNUP_SEGUE_IDENTIFIER = "SignupSegue"
/// LoginViewController -> TabBarViewController
let TAB_BAR_VIEW_CONTROLLER_NAME = "mainTabBarViewController"
/// Key for accessing rememberMeEnabled from UserDefaults
let REMEMBER_ME_KEY = "rememberMeEnabled"
/// Key for accessing lastAccessedUsername from UserDefaults
let USERNAME_KEY = "lastAccessedUsername"

/// The view controller to handle logging in to the app.
class LoginViewController: UIViewController {
    // MARK: - Properties
    /// Username of last saved credential
    fileprivate var lastAccessedUsername:String? {
        return UserDefaults.standard.object(forKey: USERNAME_KEY) as? String
    }

    /// Whether rememberMe is enabled or not
    fileprivate var rememberMeEnabled:Bool {
        let enabled = UserDefaults.standard.object(forKey: REMEMBER_ME_KEY) as? Bool
        return enabled ?? false
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
        checkRememberedCredentials()
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

                if self.rememberMeEnabled {
                    self.saveAccountDetailsToKeychain(account: email, password: password)
                } else {
                    self.clearRememberedCredentials()
                }
                self.loginSucceeded()
            }
        }
    }

    /// If rememberMeSwitch turned off, remove saved credentials from memory
    @IBAction func rememberMeValueChanged(_ sender: Any) {
        UserDefaults.standard.set(rememberMeSwitch.isOn, forKey: REMEMBER_ME_KEY)
        if !rememberMeEnabled {
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
        }
    }

    // MARK: - Saved Credentials
    /// Checks if Remember Me was previously activated and activates it if so.
    //  Then checks if user credentials were saved and fills them if appropriate
    func checkRememberedCredentials() {
        // Set Remember Me Switch
        rememberMeSwitch.isOn = rememberMeEnabled
        if rememberMeEnabled {
            // Check that a username was saved
            guard let username = lastAccessedUsername else { return }

            // Set username field
            emailTextField.text = username

            // Load saved password for user
            loadPasswordFromKeychain(username)
        }
    }

    /// Clears any saved credentials from UserDefaults
    fileprivate func clearRememberedCredentials() {
        if let username = lastAccessedUsername {
            removePasswordFromKeychain(username)
        }
        // Remove saved username from UserDefaults
        UserDefaults.standard.removeObject(forKey: USERNAME_KEY)
    }

    /// Saves the given account details to the keychain
    fileprivate func saveAccountDetailsToKeychain(account: String, password: String) {
        guard !account.isEmpty, !password.isEmpty else { return }
        // Save username to UserDefaults
        UserDefaults.standard.set(account, forKey: USERNAME_KEY)
        // Save password to keychain
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do {
            try passwordItem.savePassword(password)
        } catch {
            // TODO: Handle error saving password
        }
    }

    /// Loads in the saved password for the given user
    fileprivate func loadPasswordFromKeychain(_ account: String) {
        guard !account.isEmpty else { return }
        let passwordItem = KeychainPasswordItem(service:   KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do {
            let storedPassword = try passwordItem.readPassword()
            passwordTextField.text = storedPassword
        } catch KeychainPasswordItem.KeychainError.noPassword {
            // TODO: Handle error from no saved password
        } catch {
            // TOOD: Handle unexpected error
        }
    }

    /// Deletes the saved password from the keychain
    fileprivate func removePasswordFromKeychain(_ account: String) {
        guard !account.isEmpty else { return }
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do {
            try passwordItem.deleteItem()
        } catch {
            // TODO: Handle error deleting saved password
        }
    }

    /// Loads password from keychain and logs user in
    fileprivate func loadPasswordFromKeychainAndAuthenticateUser(_ account: String) {
        guard !account.isEmpty else { return }
        let passwordItem = KeychainPasswordItem(service:   KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do {
            let storedPassword = try passwordItem.readPassword()
            // Show the loading animation
            let hud = LoadingHUD(self.view)
            self.view.endEditing(true)
            // Log the user in
            UsersDatabase.shared.loginUser(withEmail: account,
                                           password: storedPassword) {(uid, error) in
                                            // Stop the loading animation
                                            hud.end()

                                            if let error = error {
                                                self.alert(title: "Error", message: error.localizedDescription)
                                            } else {
                                                self.loginSucceeded()
                                            }
            }
        } catch KeychainPasswordItem.KeychainError.noPassword {
            // TODO: Handle error from no saved password
        } catch {
            // TOOD: Handle unexpected error
        }
    }

    // MARK: - Biometrics Authentication
    /// Uses biometrics to authenticate user
    fileprivate func authenticateUserUsingBiometrics() {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            self.evaluateBiometricsAuthenticity(context: context)
        }
    }

    /// Executes biometric authentication and handles success or failure
    func evaluateBiometricsAuthenticity(context: LAContext) {
        guard let lastAccessedUserName = UserDefaults.standard.object(forKey: USERNAME_KEY) as? String else { return }
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: lastAccessedUserName) { (authSuccessful, authError) in
            if authSuccessful {
                self.loadPasswordFromKeychainAndAuthenticateUser(lastAccessedUserName)
            } else {
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
            break
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
