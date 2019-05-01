//
//  PasswordSettingsViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// The view controller to allow a user to change their account's password.
class PasswordSettingsViewController: UIViewController {

    static let validIcon = String.fontAwesomeIcon(name: .checkCircle)
    static let invalidIcon = String.fontAwesomeIcon(name: .timesCircle)
    static let defaultIcon = String.fontAwesomeIcon(name: .minusCircle)

    static let validConfirmPasswordMessage = ""
    static let invalidConfirmPasswordMessage = "Does not match password"
    static let defaultConfirmPasswordMessage = ""

    // MARK: - Outlets
    
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordMessageLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var validConfirmPasswordLabel: UILabel!

    // MARK: - Lifecycle
    
    /// Sets up the text fields
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPasswordTextField.clearButtonMode = UITextField.ViewMode.always
        newPasswordTextField.clearButtonMode = UITextField.ViewMode.always
        confirmNewPasswordTextField.clearButtonMode =
            UITextField.ViewMode.always
    }

    // MARK: - Actions
    
    /// Attempt to change the user's password when the save button is pressed
    @IBAction func saveTouchUp(_ sender: Any) {
        // Hide the keyboard
        self.view.endEditing(true)
        
        // Start loading animation
        self.navigationItem.hidesBackButton = true
        let hud = LoadingHUD(self.view)
        
        // Ensure valid values are given
        guard let currentPassword = currentPasswordTextField.text else {return}
        guard let newPassword = newPasswordTextField.text else {return}
        guard let email = UsersDatabase.currentUserEmail else {return}

        // Attempt to change the password
        UsersDatabase.shared.changeUserPassword(
            email: email,
            currentPassword: currentPassword,
            newPassword: newPassword) {(error) in
            
            // Stop the loading animation
            hud.end()
            self.navigationItem.hidesBackButton = false
            
            if let error = error {
                // Failed to save the password
                self.alert(title: "Error",
                           message: error.localizedDescription)
            } else {
                // Successfully saved the password
                self.alert(title: "Saved", completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }

    // TODO: do we need all three for each or will just ValueChanged work?
    @IBAction func passwordFieldEditingChanged(_ sender: Any) {
        setConfirmPasswordMessage()
    }
    @IBAction func passwordFieldEditingDidEnd(_ sender: Any) {
        setConfirmPasswordMessage()
    }
    @IBAction func passwordFieldValueChanged(_ sender: Any) {
        setConfirmPasswordMessage()
    }

    @IBAction func confirmPasswordTextFieldEditingChanged(_ sender: Any) {
        setConfirmPasswordMessage()
    }
    @IBAction func confirmPasswordFieldEditingDidEnd(_ sender: Any) {
        setConfirmPasswordMessage()
    }
    @IBAction func confirmPasswordFieldValueChanged(_ sender: Any) {
        setConfirmPasswordMessage()
    }

    // MARK: - Confirm Password Message
    
    /// Display whether or not the user entered a valid password and
    /// password confirmation.
    func setConfirmPasswordMessage() {
        if let confirmPassword = confirmNewPasswordTextField.text,
            let password = newPasswordTextField.text {
            if (confirmPassword == password) {
                // Passwords match
                setConfirmPasswordMessageValid()
                saveButton.isEnabled = true
            } else {
                // Passwords do not match
                setConfirmPasswordMessageInvalid()
                saveButton.isEnabled = false
            }
        } else {
            setConfirmPasswordMessageDefault()
        }
    }

    /// Display that the password and password confirmation is valid
    func setConfirmPasswordMessageValid() {
        validConfirmPasswordLabel.textColor = UIColor.green
        validConfirmPasswordLabel.text =
            PasswordSettingsViewController.validIcon
        confirmPasswordMessageLabel.text =
            PasswordSettingsViewController.validConfirmPasswordMessage
    }

    /// Display that the password and password confirmation is invalid
    func setConfirmPasswordMessageInvalid() {
        validConfirmPasswordLabel.textColor = UIColor.red
        validConfirmPasswordLabel.text =
            PasswordSettingsViewController.invalidIcon
        confirmPasswordMessageLabel.text =
            PasswordSettingsViewController.invalidConfirmPasswordMessage
    }

    /// Display the default message
    func setConfirmPasswordMessageDefault() {
        validConfirmPasswordLabel.textColor = UIColor.black
        validConfirmPasswordLabel.text =
            PasswordSettingsViewController.defaultIcon
        confirmPasswordMessageLabel.text =
            PasswordSettingsViewController.defaultConfirmPasswordMessage
    }
}
