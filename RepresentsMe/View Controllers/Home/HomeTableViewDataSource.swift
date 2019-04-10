//
//  HomeTableViewDataSource.swift
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
class HomeTableViewDataSource: NSObject, UITableViewDataSource {
    
    var parent:HomeViewController
    var officials:[Official] = [] {
        didSet {
            // Update the table data when new Officials are set
            updateTableData()
        }
    }
    
    /// Initialize this data source for the given HomeViewController
    ///
    /// - Parameter for:    the parent view controller
    init(for parent:HomeViewController) {
        self.parent = parent
    }
    
    /// Gets the Official at the given index
    ///
    /// - Parameter at:     the index to get
    ///
    /// - Returns: the Official
    func getOfficial(at index:Int) -> Official {
        return self.officials[index]
    }
    
    /// The number of rows is the number of Officials
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.officials.count
    }
    
    /// Set the cell for the Official at the given index
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: OFFICIAL_CELL_IDENTIFIER,
            for: indexPath) as! OfficialCell
        
        cell.official = self.officials[indexPath.row]
        
        return cell
    }
    
    /// Updates the table view with the new officials
    private func updateTableData() {
        DispatchQueue.main.async {
            switch self.parent.reachType {
            case .home, .event:
                self.parent.navigationItem.title = "Home"
                break
            case .map:
                let title = "\(self.parent.address!.city), " +
                            self.parent.address!.state
                self.parent.navigationItem.title = title
                break
            }
            
            self.parent.officialsTableView.reloadData()
        }
    }
}
