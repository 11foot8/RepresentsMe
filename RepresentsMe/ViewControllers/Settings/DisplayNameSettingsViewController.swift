//
//  DisplayNameSettingsViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// The view controller for the user to change their display name
class DisplayNameSettingsViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var displayNameTextField: UITextField!

    // MARK: - Lifecycle
    
    /// Set the user's current display name
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameTextField.text = UsersDatabase.currentUserDisplayName
    }

    // MARK: - Actions
    // TODO: Disable save button until all fields are valid
    
    /// Update the user's display name when the save button is pressed
    @IBAction func saveTouchUp(_ sender: Any) {
        self.view.endEditing(true)
        // Start loading animation
        self.navigationItem.hidesBackButton = true
        let hud = LoadingHUD(self.view)
        guard let displayName = displayNameTextField.text else { return }

        UsersDatabase.shared.changeUserDisplayName(
            newDisplayName: displayName) {(error) in
            
            // Stop the loading animation
            hud.end()
            self.navigationItem.hidesBackButton = false
            
            if let error = error {
                self.alert(title: "Error", message: error.localizedDescription)
            } else {
                self.alert(title: "Saved")
            }
        }
    }
}
