//
//  PasswordSettingsViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

class PasswordSettingsViewController: UIViewController {
    // MARK: - Properties
    let validFontAwesomeString = "check-circle"
    let invalidFontAwesomeString = "times-circle"
    let defaultFontAwesomeString = "minus-circle"

    let validConfirmPasswordMessage = ""
    let invalidConfirmPasswordMessage = "Does not match password"
    let defaultConfirmPasswordMessage = ""

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPasswordTextField.clearButtonMode = UITextField.ViewMode.always
        newPasswordTextField.clearButtonMode = UITextField.ViewMode.always
        confirmNewPasswordTextField.clearButtonMode = UITextField.ViewMode.always
    }

    // MARK: - Outlets
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordMessageLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var validConfirmPasswordLabel: UILabel!

    // MARK: - Actions
    @IBAction func saveTouchUp(_ sender: Any) {
        self.view.endEditing(true)
        // Start loading animation
        self.navigationItem.hidesBackButton = true
        let hud = LoadingHUD(self.view)
        guard let currentPassword = currentPasswordTextField.text else { return }
        guard let newPassword = newPasswordTextField.text else { return }
        guard let email = UsersDatabase.currentUserEmail else { return }

        UsersDatabase.shared.changeUserPassword(email: email, currentPassword: currentPassword, newPassword: newPassword, completion: { (error) in
            if let _ = error {
                // TODO: Handle error
                // End loading animation
                hud.end()
                self.navigationItem.hidesBackButton = false
                let alert = UIAlertController(
                    title: "Error",
                    message: "\(error.debugDescription)",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            } else {
                // End loading animation
                hud.end()
                self.navigationItem.hidesBackButton = false
                let alert = UIAlertController(
                    title: "Saved",
                    message: nil,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))

                self.present(alert, animated: true, completion: nil)
            }
        })
    }

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
    func setConfirmPasswordMessage() {
        if let confirmPassword = confirmNewPasswordTextField.text, let password = newPasswordTextField.text {
            if (confirmPassword == password) {
                setConfirmPasswordMessageValid()
                saveButton.isEnabled = true
            } else {
                setConfirmPasswordMessageInvalid()
                saveButton.isEnabled = false
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
