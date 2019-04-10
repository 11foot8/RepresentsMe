//
//  HomeTableViewDelegate.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/10/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit


/// The delegate for the Officials table view on the HomeViewController
class HomeTableViewDelegate: NSObject, UITableViewDelegate {
    
    var parent:HomeViewController
    
    /// Initializes this delegate for the given HomeViewController
    ///
    /// - Parameter for:    the HomeViewController
    init(for parent:HomeViewController) {
        self.parent = parent
    }
    
    /// Handle when a cell is selected.
    /// If viewing in home or sandbox mode, show the details for that Official.
    /// If viewing in event mode, send the selected Official back to the
    /// delegate.
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        switch self.parent.reachType {
        case .home, .map:
            // Show the details for the selected Official
            self.parent.performSegue(
                withIdentifier: HomeViewController.DETAILS_VIEW_SEGUE,
                sender: self)
            break
        case .event:
            // Send the selected Official back to the delegate and dismiss
            // the view
            let official = self.parent.tableViewDataSource.getOfficial(
                at: indexPath.row)
            self.parent.delegate?.didSelectOfficial(official: official)
            self.parent.navigationController?.popViewController(animated: true)
            
            // Deselect the row
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}
