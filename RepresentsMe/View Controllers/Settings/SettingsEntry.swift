//
//  SettingsEntry.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/10/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// An entry in a section of the settings table view.
/// Each entry has a name and icon and handles behavior when selected.
/// If the entry is a segue entry, when selected the entry will segue to its
/// specified segue identifier.
/// If the entry is a logout entry, when selected the entry will log out the
/// user.
class SettingsEntry {
    
    /// The types of settings entries
    enum EntryType {
        case segue      // Entries that segue to another view
        case logout     // Entries that log the user out
    }
    
    var parent:SettingsViewController   // The view controller to segue with
    var option:EntryType                // The type of the entry
    var name:String                     // The name of the entry
    var icon:String                     // The icon for the entry
    var subtitle:String?                // The subtitle for the entry
    var segueID:String?                 // The segue for the entry

    /// Initializes this SettingsEntry with its attributes
    ///
    /// - Parameter parent:     the SettingsViewController
    /// - Parameter option:     the type of the entry
    /// - Parameter name:       the name of the entry
    /// - Parameter subtitle:   the subtitle for the entry (default "").
    /// - Parameter segueID:    the ID of the segue (default nil).
    init(parent:SettingsViewController,
         option:EntryType,
         name:String,
         icon:FontAwesome,
         subtitle:String? = "",
         segueID:String? = nil) {
        self.parent = parent
        self.option = option
        self.name = name
        self.icon = String.fontAwesomeIcon(name: icon)
        self.subtitle = subtitle
        self.segueID = segueID
    }
    
    /// Handles this entry being selected.
    /// If the entry is a segue entry, segues to the entry's segueID.
    /// If the entry is a logout entry, logs the user out.
    func selected() {
        switch self.option {
        case .segue:
            if let segueID = self.segueID {
                self.parent.performSegue(withIdentifier: segueID,
                                         sender: self.parent)
            }
        case .logout:
            self.logout()
        }
    }
    
    /// Logs out the user.
    /// If successfully logs out, returns the user to the login view
    private func logout() {
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
