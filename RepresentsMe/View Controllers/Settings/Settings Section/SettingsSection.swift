//
//  SettingsSection.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/10/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

/// A section in the settings table view.
/// Each section has a name and an Array of SettingsEntry that are the entries
/// for that section.
class SettingsSection {
    
    var name:String
    var entries:[SettingsEntry] = []
    
    /// Initializes this SettingsSection with the given attributes
    ///
    /// - Parameter name:       the name of the section
    /// - Parameter entries:    the SettingsEntries for the section
    init(name:String, entries:[SettingsEntry]) {
        self.name = name
        self.entries = entries
    }
}
