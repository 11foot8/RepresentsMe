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
        dividerView.layer.cornerRadius = 2.0
        dividerView.clipsToBounds = true

        currentEmailTextField.text = usersDB.getCurrentUserEmail()

        // Do any additional setup after loading the view.
    }

    // MARK: - Outlets
    @IBOutlet weak var currentEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var dividerView: UIView!

    // MARK: - Actions
    // TODO: Disable save button until all fields are valid
    @IBAction func saveTouchUp(_ sender: Any) {
        self.view.endEditing(true)
        // Start loading animation
        self.navigationItem.hidesBackButton = true
        let hud = LoadingHUD(self.view)
        guard let currentEmail = currentEmailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let newEmail = newEmailTextField.text else { return }

        usersDB.changeUserEmail(currentEmail: currentEmail, password: password, newEmail: newEmail, completion: { (error) in
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
}
