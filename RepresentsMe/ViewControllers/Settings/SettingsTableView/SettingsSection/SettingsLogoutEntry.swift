//
//  SettingsLogoutEntry.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/10/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// An entry in a section of the settings table view.
/// Logout entries log the user out when they are selected.
class SettingsLogoutEntry: SettingsEntry {
    
    /// Handles this entry being selected.
    /// Logs the user out and returns the the user to the login view.
    override func selected() {
        UsersDatabase.shared.logoutUser {(error) in
            if error != nil {
                // TODO: Handle error
            } else {
                // Return the user to the login view
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let entryViewController = storyBoard.instantiateViewController(
                    withIdentifier: "entryViewController")
                if let appDel = UIApplication.shared.delegate as? AppDelegate {
                    appDel.window?.rootViewController = entryViewController
                }
            }
        }
    }
}
