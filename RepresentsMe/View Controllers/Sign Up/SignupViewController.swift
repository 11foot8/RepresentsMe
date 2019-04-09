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

    let usersDB = UsersDatabase.getInstance()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.clearButtonMode = UITextField.ViewMode.always
        passwordTextField.clearButtonMode = UITextField.ViewMode.always
        confirmPasswordTextField.clearButtonMode = UITextField.ViewMode.always
        displayNameTextField.clearButtonMode = UITextField.ViewMode.always
    }

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!

    // MARK: - Actions
    @IBAction func signUpDidTouch(_ sender: Any) {
        attemptCreateUser()
    }
    @IBAction func cancelTouchUp(_ sender: Any) {
        performSegue(withIdentifier: "SignupUnwindSegue", sender: self)
    }

    func attemptCreateUser() {
        // Check all values are valid
        guard let email = emailTextField.text else {
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
