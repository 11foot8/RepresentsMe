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
/// SettingsEntries should not be initiated directly, instead classes that
/// inhert from SettingsEntry should be instantiated.
/// Inheriting classes must implement SettingsEntry#selected()
class SettingsEntry {

    var parent:SettingsViewController   // The view controller to segue with
    var name:String                     // The name of the entry
    var icon:String                     // The icon for the entry
    var subtitle:String?                // The subtitle for the entry

    /// Initializes this SettingsEntry with its attributes
    ///
    /// - Parameter parent:     the SettingsViewController
    /// - Parameter name:       the name of the entry
    /// - Parameter subtitle:   the subtitle for the entry (default "").
    init(parent:SettingsViewController,
         name:String,
         icon:FontAwesome,
         subtitle:String? = "") {
        self.parent = parent
        self.name = name
        self.icon = String.fontAwesomeIcon(name: icon)
        self.subtitle = subtitle
    }
    
    /// Handles this entry being selected.
    /// Must be implemented by inheriting classes.
    func selected() {
        fatalError("Not implemented by inheriting class")
    }
}
