//
//  EventsTableViewDelegate.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/10/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// The delegate for the events table view
class EventsTableViewDelegate: NSObject, UITableViewDelegate {
    
    /// Deselect a cell after it is selected
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
