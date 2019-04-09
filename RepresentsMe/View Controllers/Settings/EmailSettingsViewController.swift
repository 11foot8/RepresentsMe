//
//  EmailSettingsViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

class EmailSettingsViewController: UIViewController {
    // MARK: - Properties
    let usersDB = UsersDatabase.getInstance()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Outlets
    @IBOutlet weak var currentEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newEmailTextField: UITextField!

    // MARK: - Actions
    @IBAction func saveTouchUp(_ sender: Any) {
        self.view.endEditing(true)
        // TODO: Start loading animation
        guard let currentEmail = currentEmailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let newEmail = newEmailTextField.text else { return }

        usersDB.changeUserEmail(currentEmail: currentEmail, password: password, newEmail: newEmail, completion: { (error) in
            if let _ = error {
                // TODO: Handle error
                // TODO: Stop loading animation
                let alert = UIAlertController(
                    title: "Error",
                    message: "\(error.debugDescription)",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            } else {
                // TODO: Stop loading animation
                let alert = UIAlertController(
                    title: "Saved",
                    message: nil,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))

                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}
