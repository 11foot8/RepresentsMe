//
//  OfficialsTableViewDataSource.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/10/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

let OFFICIAL_CELL_IDENTIFIER = "officialCell"

/// The data source for the Officials table on the HomeViewController.
/// Manages the Array of Officials being displayed and manages which Official
/// is displayed where in the table view.
class OfficialsTableViewDataSource: NSObject, UITableViewDataSource {
    
    var parent:OfficialsListViewController

    /// Initialize this data source for the given HomeViewController
    ///
    /// - Parameter for:    the parent view controller
    init(for parent:OfficialsListViewController) {
        self.parent = parent
    }

    /// The number of rows is the number of Officials
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch self.parent.reachType {
        case .home, .event:
            return AppState.homeOfficials.count
        case .map:
            return AppState.sandboxOfficials.count
        }
    }
    
    /// Set the cell for the Official at the given index
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: OFFICIAL_CELL_IDENTIFIER,
            for: indexPath) as! OfficialCell
        
        switch self.parent.reachType {
        case .home, .event:
            cell.official = AppState.homeOfficials[indexPath.row]
            break
        case .map:
            cell.official = AppState.sandboxOfficials[indexPath.row]
            break
        }
        
        switch self.parent.reachType {
        case .home, .map:
            cell.accessoryType = .disclosureIndicator
            break
        case .event:
            cell.accessoryType = .none
            break
        }
        
        return cell
    }
}
