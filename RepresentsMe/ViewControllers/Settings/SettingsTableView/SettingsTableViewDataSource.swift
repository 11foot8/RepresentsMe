//
//  SettingsTableViewDataSource.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/10/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

let SETTINGS_CELL_IDENTIFIER = "settingsCell"

/// The data source for the settings table view
class SettingsTableViewDataSource: NSObject, UITableViewDataSource {
    
    var parent:SettingsViewController
    var sections:[SettingsSection] = []
    
    /// Initializes this data source for the given SettingsViewController.
    /// Creates the sections and entries for the table
    ///
    /// - Parameter for:    the SettingsViewController
    init(for parent:SettingsViewController) {
        self.parent = parent
        super.init()
        self.initializeSections(with: parent)
    }
    
    /// Selects the entry at the given index path
    ///
    /// - Parameter at:     the selected IndexPath
    func selected(at indexPath:IndexPath) {
        self.sections[indexPath.section].entries[indexPath.row].selected()
    }

    /// Number of sections is the number of entries in data
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    /// Number of rows in a section si the number of entries in its Array
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].entries.count
    }
    
    /// Sets the views for the cell at the given index
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SETTINGS_CELL_IDENTIFIER) as! SettingsCell
        
        let section = self.sections[indexPath.section]
        let entry = section.entries[indexPath.row]
        
        cell.imageLabel.text = entry.icon
        cell.titleLabel.text = entry.name
        cell.subtitleLabel.text = entry.subtitle
        
        return cell
    }

    /// Gets the title for the given section
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].name
    }
    
    /// Initializes the sections for the table
    ///
    /// - Parameter with:   the SettingsViewController
    private func initializeSections(with parent:SettingsViewController) {
        self.sections = [
            SettingsSection(name: "User", entries: [
                SettingsSegueEntry(
                    parent: parent,
                    name: "Email",
                    icon: .envelope,
                    segueID: "EmailSettingsSegue",
                    subtitle: UsersDatabase.currentUserEmail),
                SettingsSegueEntry(
                    parent: parent,
                    name: "Username",
                    icon: .user,
                    segueID: "DisplayNameSettingsSegue",
                    subtitle: UsersDatabase.currentUserDisplayName),
                SettingsSegueEntry(
                    parent: parent,
                    name: "Password",
                    icon: .key,
                    segueID: "PasswordSettingsSegue")
                ]),
            SettingsSection(name: "", entries: [
                SettingsSegueEntry(
                    parent: parent,
                    name: "Address",
                    icon: .home,
                    segueID: "AddressSettingsSegue")
                ]),
            SettingsSection(name: "", entries: [
                SettingsLogoutEntry(
                    parent: parent,
                    name: "Logout",
                    icon: .signOutAlt)
                ])
        ]
    }
}
