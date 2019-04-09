//
//  DisplayNameSettingsViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

class DisplayNameSettingsViewController: UIViewController {
    // MARK: - Properties
    let usersDB = UsersDatabase.getInstance()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameTextField.text = usersDB.getCurrentUserDisplayName()
        // Do any additional setup after loading the view.
    }

    // MARK: - Outlets
    @IBOutlet weak var displayNameTextField: UITextField!

    // MARK: - Actions
    // TODO: Disable save button until all fields are valid
    @IBAction func saveTouchUp(_ sender: Any) {
        self.view.endEditing(true)
        // TODO: Start loading animation
        guard let displayName = displayNameTextField.text else { return }

        usersDB.changeUserDisplayName(newDisplayName: displayName) { (error) in
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
        }
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
