//
//  SignupViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {

    // MARK: - Properties
    let addressSegueIdentifier = "CreateAccountAddressSegue"

    let validFontAwesomeString = "check-circle"
    let invalidFontAwesomeString = "times-circle"
    let defaultFontAwesomeString = "minus-circle"

    let validEmailMessage = ""
    let invalidEmailMessage = "Invalid Email"
    let defaultEmailMessage = ""

    let validPasswordMessage = ""
    let invalidPasswordMessage = "InvalidPassword"
    let defaultPasswordMessage = ""

    let validConfirmPasswordMessage = ""
    let invalidConfirmPasswordMessage = "Does not match password"
    let defaultConfirmPasswordMessage = ""


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.clearButtonMode = UITextField.ViewMode.always
        passwordTextField.clearButtonMode = UITextField.ViewMode.always
        confirmPasswordTextField.clearButtonMode = UITextField.ViewMode.always
        displayNameTextField.clearButtonMode = UITextField.ViewMode.always

        setEmailMessage()
        setPasswordMessage()
        setConfirmPasswordMessage()
    }

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

    // MARK: - Actions
    @IBAction func signUpDidTouch(_ sender: Any) {
        attemptCreateUser()
    }

    @IBAction func cancelTouchUp(_ sender: Any) {
        performSegue(withIdentifier: "SignupUnwindSegue", sender: self)
    }

    @IBAction func emailFieldEditingChanged(_ sender: Any) {
        setEmailMessage()
    }

    @IBAction func passwordFieldEditingChanged(_ sender: Any) {
        setPasswordMessage()
    }

    @IBAction func confirmPasswordFieldEditingChanged(_ sender: Any) {
        setConfirmPasswordMessage()
    }

    func attemptCreateUser() {
        // Check all values are valid
        guard let email = emailTextField.text, Util.isValidEmail(testStr: email) else {
            // TODO: Handle Error
            return
        }
        guard let password = passwordTextField.text else {
            // TODO: Handle Error
            return
        }
        guard let confirmPassword = confirmPasswordTextField.text else {
            // TODO: Handle Error
            return
        }

        guard let displayName = displayNameTextField.text else {
            // TODO: Handle Error
            return
        }

        // TODO: Check that email is in correct form

        guard password == confirmPassword else {
            // TODO: Alert users passwords dont match
            return
        }
    }

    // MARK: - Email Message
    func setEmailMessage() {
        if let email = emailTextField.text {
            if Util.isValidEmail(testStr: email) {
                setEmailMessageValid()
            } else {
                setEmailMessageInvalid()
            }
        } else {
            setEmailMessageDefault()
        }
    }

    func setEmailMessageValid() {
        validEmailLabel.textColor = UIColor.green
        validEmailLabel.text = validFontAwesomeString
        emailMessageLabel.text = validEmailMessage
    }

    func setEmailMessageInvalid() {
        validEmailLabel.textColor = UIColor.red
        validEmailLabel.text = invalidFontAwesomeString
        emailMessageLabel.text = invalidEmailMessage
    }

    func setEmailMessageDefault() {
        validEmailLabel.textColor = UIColor.black
        validEmailLabel.text = defaultFontAwesomeString
        emailMessageLabel.text = defaultEmailMessage
    }

    // MARK: - Password Message
    func setPasswordMessage() {
        setConfirmPasswordMessage()
        setPasswordMessageDefault()
    }

    func setPasswordMessageValid() {
        validPasswordLabel.textColor = UIColor.green
        validPasswordLabel.text = validFontAwesomeString
        passwordMessageLabel.text = validPasswordMessage
    }

    func setPasswordMessageInvalid() {
        validPasswordLabel.textColor = UIColor.red
        validPasswordLabel.text = invalidFontAwesomeString
        passwordMessageLabel.text = invalidPasswordMessage
    }

    func setPasswordMessageDefault() {
        validPasswordLabel.textColor = UIColor.black
        validPasswordLabel.text = ""
        passwordMessageLabel.text = defaultPasswordMessage
    }

    // MARK: - Confirm Password Message
    func setConfirmPasswordMessage() {
        if let confirmPassword = confirmPasswordTextField.text, let password = passwordTextField.text {
            if (confirmPassword == password) {
                setConfirmPasswordMessageValid()
            } else {
                setConfirmPasswordMessageInvalid()
            }
        } else {
            setConfirmPasswordMessageDefault()
        }
    }

    func setConfirmPasswordMessageValid() {
        validConfirmPasswordLabel.textColor = UIColor.green
        validConfirmPasswordLabel.text = validFontAwesomeString
        confirmPasswordMessageLabel.text = validConfirmPasswordMessage
    }

    func setConfirmPasswordMessageInvalid() {
        validConfirmPasswordLabel.textColor = UIColor.red
        validConfirmPasswordLabel.text = invalidFontAwesomeString
        confirmPasswordMessageLabel.text = invalidConfirmPasswordMessage
    }

    func setConfirmPasswordMessageDefault() {
        validConfirmPasswordLabel.textColor = UIColor.black
        validConfirmPasswordLabel.text = defaultFontAwesomeString
        confirmPasswordMessageLabel.text = defaultConfirmPasswordMessage
    }

    // MARK: Segue functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addressSegueIdentifier {
            let enterAddressViewController = segue.destination as! EnterAddressViewController
            enterAddressViewController.email = emailTextField.text!
            enterAddressViewController.password = passwordTextField.text!
            enterAddressViewController.displayName = displayNameTextField.text!
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)

    }
}
