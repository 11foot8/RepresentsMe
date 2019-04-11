//
//  LoginViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MBProgressHUD

// LoginViewController -> SignupViewController
let SIGNUP_SEGUE_IDENTIFIER = "SignupSegue"
let TAB_BAR_VIEW_CONTROLLER_NAME = "mainTabBarViewController"

/// The view controller to handle logging in to the app.
class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: - Lifecycle
    
    /// Set the properties for text fields
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.clearButtonMode = UITextField.ViewMode.always
        passwordTextField.clearButtonMode = UITextField.ViewMode.always
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
                                       password: password) {(uid, error) in
            // Stop the loading animation
            hud.end()
                                        
            if let error = error {
                self.alert(title: "Error", message: error.localizedDescription)
            } else {
                self.loginSucceeded()
            }
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
