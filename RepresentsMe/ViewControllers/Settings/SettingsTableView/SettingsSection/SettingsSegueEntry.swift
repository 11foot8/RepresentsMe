//
//  SettingsSegueEntry.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/10/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// A entry in a section of the settings table view.
/// Segue entries perform a segue with their identifier when they are selected.
class SettingsSegueEntry: SettingsEntry {
    
    var segueID:String      // The segue identifier for this entry
    
    /// Initializes this SettingsEntry with its attributes
    ///
    /// - Parameter parent:     the SettingsViewController
    /// - Parameter option:     the type of the entry
    /// - Parameter name:       the name of the entry
    /// - Parameter segueID:    the ID of the segue.
    /// - Parameter subtitle:   the subtitle for the entry (default "").
    init(parent:SettingsViewController,
         name:String,
         icon:FontAwesome,
         segueID:String,
         subtitle:String? = "") {
        self.segueID = segueID
        super.init(parent: parent,
                   name: name,
                   icon: icon,
                   subtitle: subtitle)
    }
    
    /// Handles this entry being selected.
    /// Segues to the segue identifier for this entry
    override func selected() {
        self.parent.performSegue(withIdentifier: segueID, sender: self.parent)
    }
}
