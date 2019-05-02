//
//  SettingsTableViewDelegate.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/10/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// The delegate for the settings table view
class SettingsTableViewDelegate: NSObject, UITableViewDelegate {
    
    var parent:SettingsViewController
    
    /// Initializes this delegate for the given SettingsViewController
    ///
    /// - Parameter for:    the SettingsViewController
    init(for parent:SettingsViewController) {
        self.parent = parent
    }
    
    /// Gets the view for a section footer
    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(
            frame: CGRect(x: 0,
                          y: 0,
                          width: self.parent.view.bounds.size.width,
                          height: 20))
        footerView.backgroundColor = .groupTableViewBackground
        return footerView
    }
    
    /// Handles when a cell is selected
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        self.parent.tableViewDataSource.selected(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}
