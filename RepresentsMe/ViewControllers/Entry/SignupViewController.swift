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
// SignupViewController -> LoginViewController
let SIGNUP_UNWIND_SEGUE_IDENTIFIER = "SignupUnwindSegue"

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
    static let invalidPasswordMessage = "InvalidPassword"
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
        performSegue(withIdentifier: "SignupUnwindSegue", sender: self)
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

    /// Checks that all fields are correctly filled out.
    /// If all fields are correctly filled out, enables the continue button,
    /// otherwise disables the continue button.
    func checkFields() {
        if setEmailMessage() &&
            setPasswordMessage() {
            // All fields are correctly filled out, let the user continue
            continueButton.isEnabled = true
        } else {
            // Some fields are not correctly filled out
            continueButton.isEnabled = false
        }
    }

    // MARK: - Email Message
    
    /// Checks that the entered email is valid.
    /// Updates the email validity indicator.
    ///
    /// - Returns: true if the email is a valid email, false otherwise
    func setEmailMessage() -> Bool {
        if let email = emailTextField.text {
            if Util.isValidEmail(testStr: email) {
                setEmailMessageValid()
                return true
            } else {
                setEmailMessageInvalid()
                return false
            }
        } else {
            setEmailMessageDefault()
            return false
        }
    }

    /// Displays that the entered email is valid
    func setEmailMessageValid() {
        validEmailLabel.textColor = UIColor.green
        validEmailLabel.text = SignupViewController.validIcon
        emailMessageLabel.text =
            SignupViewController.validEmailMessage
    }

    /// Displays that the entered email is invalid
    func setEmailMessageInvalid() {
        validEmailLabel.textColor = UIColor.red
        validEmailLabel.text = SignupViewController.invalidIcon
        emailMessageLabel.text =
            SignupViewController.invalidEmailMessage
    }

    /// Displays the default email indicator
    func setEmailMessageDefault() {
        validEmailLabel.textColor = UIColor.black
        validEmailLabel.text = SignupViewController.defaultIcon
        emailMessageLabel.text =
            SignupViewController.defaultEmailMessage
    }

    // MARK: - Password Message
    
    /// Checks that the entered password is valid.
    /// Updates the indicator for the password validity.
    ///
    /// - Returns: true if the password and password confirmation is valid,
    ///            false otherwise
    func setPasswordMessage() -> Bool {
        setPasswordMessageDefault()
        return setConfirmPasswordMessage()
    }

    /// Displays that the entered password is valid
    func setPasswordMessageValid() {
        validPasswordLabel.textColor = UIColor.green
        validPasswordLabel.text = SignupViewController.validIcon
        passwordMessageLabel.text =
            SignupViewController.validPasswordMessage
    }

    /// Displays that the entered password is invalid
    func setPasswordMessageInvalid() {
        validPasswordLabel.textColor = UIColor.red
        validPasswordLabel.text = SignupViewController.invalidIcon
        passwordMessageLabel.text =
            SignupViewController.invalidPasswordMessage
    }

    /// Displays the default indicator for password validity
    func setPasswordMessageDefault() {
        validPasswordLabel.textColor = UIColor.black
        validPasswordLabel.text = ""
        passwordMessageLabel.text =
            SignupViewController.defaultPasswordMessage
    }

    // MARK: - Confirm Password Message
    
    /// Checks that the password confirmation is valid.
    /// Updates the indicator for the password confirmation validity.
    ///
    /// - Returns: true if the password confirmation is valid, false otherwise
    func setConfirmPasswordMessage() -> Bool {
        if let confirmPassword = confirmPasswordTextField.text,
            let password = passwordTextField.text {
            if (confirmPassword == password) {
                setConfirmPasswordMessageValid()
                return true
            } else {
                setConfirmPasswordMessageInvalid()
                return false
            }
        } else {
            setConfirmPasswordMessageDefault()
            return false
        }
    }

    /// Displays that the password confirmation is valid
    func setConfirmPasswordMessageValid() {
        validConfirmPasswordLabel.textColor = UIColor.green
        validConfirmPasswordLabel.text = SignupViewController.validIcon
        confirmPasswordMessageLabel.text =
            SignupViewController.validConfirmPasswordMessage
    }

    /// Displays that the password confirmation is invalid
    func setConfirmPasswordMessageInvalid() {
        validConfirmPasswordLabel.textColor = UIColor.red
        validConfirmPasswordLabel.text = SignupViewController.invalidIcon
        confirmPasswordMessageLabel.text =
            SignupViewController.invalidConfirmPasswordMessage
    }

    /// Displays the default password confirmation validity indicator
    func setConfirmPasswordMessageDefault() {
        validConfirmPasswordLabel.textColor = UIColor.black
        validConfirmPasswordLabel.text = SignupViewController.defaultIcon
        confirmPasswordMessageLabel.text =
            SignupViewController.defaultConfirmPasswordMessage
    }

    // MARK: Segue functions
    
    /// Prepare to segue to have the user enter an address
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ADDRESS_SEGUE_IDENTIFIER {
            let enterAddressViewController = segue.destination as! SignupAddressViewController
            enterAddressViewController.email = emailTextField.text!
            enterAddressViewController.password = passwordTextField.text!
            enterAddressViewController.displayName = displayNameTextField.text!
        }
    }

    /// Hide the keyboard when the user touches outside of a text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)

    }
}
