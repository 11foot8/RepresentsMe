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

// LoginViewController -> SignupViewController
let SIGNUP_SEGUE_IDENTIFIER = "SignupSegue"
let TAB_BAR_VIEW_CONTROLLER_NAME = "mainTabBarViewController"
let REMEMBER_ME_KEY = "rememberMeEnabled"
let USERNAME_KEY = "lastAccessedUsername"
let PASSWORD_KEY = "lastUsedPassword"

/// The view controller to handle logging in to the app.
class LoginViewController: UIViewController {
    
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
        let rememberMeEnabled = rememberMeSwitch.isOn
        UserDefaults.standard.set(rememberMeEnabled, forKey: REMEMBER_ME_KEY)

        // Show the loading animation
        let hud = LoadingHUD(self.view)
        self.view.endEditing(true)
        
        // Log the user in
        UsersDatabase.shared.loginUser(withEmail: email,
                                       password: password) {(uid, error) in
            // Stop the loading animation
            hud.end()
                                        
            if let error = error {
                self.alert(title: "Error", message: error.localizedDescription)
            } else {

                if rememberMeEnabled {
                    self.saveAccountDetailsToKeychain(account: email, password: password)
                }
                self.loginSucceeded()
            }
        }
    }

    // MARK: - Authentication

    /// Checks if Remember Me was previously activated and activates it if so.
    //  Then checks if user credentials were saved and fills them if appropriate
    func checkRememberedCredentials() {
        guard UserDefaults.standard.bool(forKey: REMEMBER_ME_KEY) else {
            return
        }

        let rememberMeEnabled = UserDefaults.standard.object(forKey: REMEMBER_ME_KEY) as? Bool

        // Set Remember Me Switch
        rememberMeSwitch.isOn = rememberMeEnabled!

        if rememberMeEnabled! {
            guard let lastAccessedUserName = UserDefaults.standard.object(forKey: USERNAME_KEY) as? String else {
                print("No last accessed user name")
                return
            }

            // Set username field
            emailTextField.text = lastAccessedUserName

            loadPasswordFromKeychain(lastAccessedUserName)
        }

    }

    fileprivate func authenticateUserUsingBiometrics() {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            self.evaluateBiometricsAuthenticity(context: context)
        }
    }

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

    fileprivate func loadPasswordFromKeychain(_ account: String) {
        guard !account.isEmpty else { return }
        let passwordItem = KeychainPasswordItem(service:   KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do {
            let storedPassword = try passwordItem.readPassword()
            passwordTextField.text = storedPassword
        } catch KeychainPasswordItem.KeychainError.noPassword {
            print("No saved password")
        } catch {
            print("Unhandled error")
        }
    }

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
            print("No saved password")
        } catch {
            print("Unhandled error")
        }
    }

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
        case LAError.touchIDNotEnrolled:
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


    func localAuthentication() -> Void {

        let laContext = LAContext()
        var error: NSError?
        let biometricsPolicy = LAPolicy.deviceOwnerAuthenticationWithBiometrics

        if (laContext.canEvaluatePolicy(biometricsPolicy, error: &error)) {

            if let laError = error {
                print("laError - \(laError)")
                return
            }

            var localizedReason = "Unlock device"
            if #available(iOS 11.0, *) {
                if (laContext.biometryType == LABiometryType.faceID) {
                    localizedReason = "Unlock using Face ID"
                    print("FaceId support")
                } else if (laContext.biometryType == LABiometryType.touchID) {
                    localizedReason = "Unlock using Touch ID"
                    print("TouchId support")
                } else {
                    print("No Biometric support")
                }
            } else {
                // Fallback on earlier versions
            }


            laContext.evaluatePolicy(biometricsPolicy, localizedReason: localizedReason, reply: { (isSuccess, error) in

                DispatchQueue.main.async(execute: {

                    if let laError = error {
                        print("laError - \(laError)")
                    } else {
                        if isSuccess {
                            print("success")
                        } else {
                            print("failure")
                        }
                    }

                })
            })
        }


    }

    fileprivate func saveAccountDetailsToKeychain(account: String, password: String) {
        guard !account.isEmpty, !password.isEmpty else { return }
        UserDefaults.standard.set(account, forKey: USERNAME_KEY)
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do {
            try passwordItem.savePassword(password)
        } catch {
            print("Error saving password")
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
}
