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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameTextField.text = UsersDatabase.shared.getCurrentUserDisplayName()
        // Do any additional setup after loading the view.
    }

    // MARK: - Outlets
    @IBOutlet weak var displayNameTextField: UITextField!

    // MARK: - Actions
    // TODO: Disable save button until all fields are valid
    @IBAction func saveTouchUp(_ sender: Any) {
        self.view.endEditing(true)
        // Start loading animation
        self.navigationItem.hidesBackButton = true
        let hud = LoadingHUD(self.view)
        guard let displayName = displayNameTextField.text else { return }

        UsersDatabase.shared.changeUserDisplayName(newDisplayName: displayName) { (error) in
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
