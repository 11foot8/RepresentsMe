//
//  EmailSettingsViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// View controller for the user to update their email address.
class EmailSettingsViewController: UIViewController {

    @IBOutlet weak var currentEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var dividerView: UIView!

    /// Sets up the views
    override func viewDidLoad() {
        super.viewDidLoad()
        dividerView.layer.cornerRadius = 2.0
        dividerView.clipsToBounds = true
        currentEmailTextField.text = UsersDatabase.currentUserEmail
    }

    /// Attempts to update the user's email address.
    @IBAction func saveTouchUp(_ sender: Any) {
        // Hide the keyboard
        self.view.endEditing(true)
        
        // Ensure values were set
        guard let currentEmail = currentEmailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let newEmail = newEmailTextField.text else {return}
        
        // Start loading animation
        self.navigationItem.hidesBackButton = true
        let hud = LoadingHUD(self.view)

        // Update the user's email address
        UsersDatabase.shared.changeUserEmail(
            currentEmail: currentEmail,
            password: password,
            newEmail: newEmail) {(error) in
            
            // Stop the loading animation
            hud.end()
            self.navigationItem.hidesBackButton = false
            
            if let error = error {
                // Failed to update
                self.alert(title: "Error",
                           message: error.localizedDescription)
            } else {
                // Successfully updated
                self.alert(title: "Saved", completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
}
