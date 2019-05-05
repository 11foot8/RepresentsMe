//
//  SignupViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import Firebase

// SignupViewController -> SignupAddressViewController
let ADDRESS_SEGUE_IDENTIFIER = "CreateAccountAddressSegue"
let MIN_PASSWORD_LENGTH:Int = 6

/// The view controller that starts the process for a user to create an
/// account.
class SignupViewController: UIViewController {

    // MARK: - Properties
    
    static let validIcon = String.fontAwesomeIcon(name: .checkCircle)
    static let invalidIcon = String.fontAwesomeIcon(name: .timesCircle)
    static let defaultIcon = String.fontAwesomeIcon(name: .minusCircle)

    static let validEmailMessage = ""
    static let invalidEmailMessage = "Invalid Email"
    static let defaultEmailMessage = ""

    static let validPasswordMessage = ""
    static let invalidPasswordMessage = "Password is too short"
    static let defaultPasswordMessage = ""

    static let validConfirmPasswordMessage = ""
    static let invalidConfirmPasswordMessage = "Does not match password"
    static let defaultConfirmPasswordMessage = ""

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var validEmailLabel: UILabel!
    @IBOutlet weak var validPasswordLabel: UILabel!
    @IBOutlet weak var validConfirmPasswordLabel: UILabel!
    @IBOutlet weak var emailMessageLabel: UILabel!
    @IBOutlet weak var passwordMessageLabel: UILabel!
    @IBOutlet weak var confirmPasswordMessageLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!

    // MARK: - Lifecycle
    
    /// Sets up the text fields for the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Always show the clear buttons
        emailTextField.clearButtonMode = UITextField.ViewMode.always
        passwordTextField.clearButtonMode = UITextField.ViewMode.always
        confirmPasswordTextField.clearButtonMode = UITextField.ViewMode.always
        displayNameTextField.clearButtonMode = UITextField.ViewMode.always
        
        // Set the initial state for the validity indicators
        checkFields()
    }

    // MARK: - Actions

    /// Unwind to the login view controller when the cancel button is pressed
    @IBAction func cancelTouchUp(_ sender: Any) {
        self.dismiss(animated: true)
    }

    /// Checks that the fields are valid when the email is changed
    @IBAction func emailFieldEditingChanged(_ sender: Any) {
        checkFields()
    }

    /// Checks that the fields are valid when the password is changed
    @IBAction func passwordFieldEditingChanged(_ sender: Any) {
        checkFields()
    }

    /// Checks that the fields are valid when the password confirmation is
    /// changed.
    @IBAction func confirmPasswordFieldEditingChanged(_ sender: Any) {
        checkFields()
    }

    // MARK: Segue functions
    
    /// Prepare to segue to have the user enter an address
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ADDRESS_SEGUE_IDENTIFIER {
            let enterAddressViewController = segue.destination as! SignupAddressViewController
            enterAddressViewController.email = emailTextField.text!
            enterAddressViewController.password = passwordTextField.text!
            enterAddressViewController.displayName = displayNameTextField.text!
            enterAddressViewController.previousVC = self
        }
    }

    /// Hide the keyboard when the user touches outside of a text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    /// Checks that all fields are correctly filled out.
    /// If all fields are correctly filled out, enables the continue button,
    /// otherwise disables the continue button.
    private func checkFields() {
        let emailValid = self.emailValid()
        let passwordValid = self.passwordValid()
        let confirmValid = self.passwordConfirmationValid()
        
        // Update the message for the email
        if emailValid {
            setEmailMessageValid()
        } else {
            setEmailMessageInvalid()
        }
        
        // Update the messages for the password and password confirmation
        if passwordValid {
            setPasswordMessageValid()
            if confirmValid {
                setConfirmPasswordMessageValid()
            } else {
                setConfirmPasswordMessageInvalid()
            }
        } else {
            setPasswordMessageInvalid()
            setConfirmPasswordMessageDefault()
        }
        
        // Toggle whether the continue button is enabled
        if emailValid && passwordValid && confirmValid {
            self.enableContineButton()
        } else {
            self.disableContineButton()
        }
    }
    
    /// Gets whether or not the email is valid.
    ///
    /// - Returns: true if the email is valid, false otherwise
    private func emailValid() -> Bool {
        guard let email = emailTextField.text else {return false}
        return Util.isValidEmail(testStr: email)
    }
    
    /// Gets whether or not the password is valid.
    ///
    /// - Returns: true if the password is valid, false otherwise
    private func passwordValid() -> Bool {
        guard let password = passwordTextField.text else {return false}
        return password.count >= MIN_PASSWORD_LENGTH
    }
    
    /// Gets whether or not the password confirmation is valid.
    ///
    /// - Returns: true if the password confirmation is valid, false otherwise
    private func passwordConfirmationValid() -> Bool {
        guard let password = passwordTextField.text else {return false}
        guard let confirm = confirmPasswordTextField.text else {return false}
        return password == confirm
    }

    /// Displays that the entered email is valid
    private func setEmailMessageValid() {
        validEmailLabel.textColor = UIColor.green
        validEmailLabel.text = SignupViewController.validIcon
        emailMessageLabel.text =
            SignupViewController.validEmailMessage
    }
    
    /// Displays that the entered email is invalid
    private func setEmailMessageInvalid() {
        validEmailLabel.textColor = UIColor.red
        validEmailLabel.text = SignupViewController.invalidIcon
        emailMessageLabel.text =
            SignupViewController.invalidEmailMessage
    }

    /// Displays that the entered password is valid
    private func setPasswordMessageValid() {
        validPasswordLabel.textColor = UIColor.green
        validPasswordLabel.text = SignupViewController.validIcon
        passwordMessageLabel.text =
            SignupViewController.validPasswordMessage
    }
    
    /// Displays that the entered password is invalid
    private func setPasswordMessageInvalid() {
        validPasswordLabel.textColor = UIColor.red
        validPasswordLabel.text = SignupViewController.invalidIcon
        passwordMessageLabel.text =
            SignupViewController.invalidPasswordMessage
    }

    /// Displays that the password confirmation is valid
    private func setConfirmPasswordMessageValid() {
        validConfirmPasswordLabel.textColor = UIColor.green
        validConfirmPasswordLabel.text = SignupViewController.validIcon
        confirmPasswordMessageLabel.text =
            SignupViewController.validConfirmPasswordMessage
    }
    
    /// Displays that the password confirmation is invalid
    private func setConfirmPasswordMessageInvalid() {
        validConfirmPasswordLabel.textColor = UIColor.red
        validConfirmPasswordLabel.text = SignupViewController.invalidIcon
        confirmPasswordMessageLabel.text =
            SignupViewController.invalidConfirmPasswordMessage
    }
    
    /// Displays the default password confirmation validity indicator
    private func setConfirmPasswordMessageDefault() {
        validConfirmPasswordLabel.textColor = UIColor.black
        validConfirmPasswordLabel.text = ""
        confirmPasswordMessageLabel.text =
            SignupViewController.defaultConfirmPasswordMessage
    }
    
    /// Enables to continue button
    private func enableContineButton() {
        continueButton.isEnabled = true
        continueButton.alpha = 1.0
    }
    
    /// Disables to continue button
    private func disableContineButton() {
        continueButton.isEnabled = false
        continueButton.alpha = 0.5
    }
}
