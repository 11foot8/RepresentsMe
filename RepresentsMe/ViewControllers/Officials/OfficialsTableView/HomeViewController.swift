//
//  HomeViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 2/23/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import CoreLocation

/// The protocol to implement in order to receive an Official when the user
/// selects an Official.
protocol OfficialSelectionDelegate {
    func didSelectOfficial(official: Official)
}

/// The view controller to display a table view of Officials.
/// Allows for showing the user's home Officials as well as Officials for a
/// selected Address. Also allows for selecting an Official in order to select
/// Officials for Events.
class HomeViewController: UIViewController {
    
    static let DETAILS_VIEW_SEGUE = "detailsViewSegue"

    /// The modes avaliable for the home view controller
    enum ReachType {
        case home       // Mode for showing the user's home Officials
        case map        // Mode for showing Officials from the sandbox mode
        case event      // Mode for showing Officials to select for an Event
    }

    // MARK: - Properties
    
    // The table view delegate and data source
    var tableViewDataSource:HomeTableViewDataSource!
    var tableViewDelegate:HomeTableViewDelegate!
    
    // Properties
    var reachType:ReachType = .home
    var delegate:OfficialSelectionDelegate?
    var address:Address? {
        didSet {
            addressChanged = true
        }
    }
    var addressChanged:Bool = false
    
    // MARK: - Outlets
    
    @IBOutlet weak var officialsTableView: UITableView!

    // MARK: - Lifecycle
    
    /// Set the table view delegate and data source
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the data source
        self.tableViewDataSource = HomeTableViewDataSource(for: self)
        officialsTableView.dataSource = self.tableViewDataSource
        
        // Set the delegate
        self.tableViewDelegate = HomeTableViewDelegate(for: self)
        officialsTableView.delegate = self.tableViewDelegate
        
    }

    /// Update the Officials if the address changed
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch reachType {
        case .home, .event:
            // Using the home Officials
            self.updateHomeOfficials()
            break
        case .map:
            // Using the sandbox Officials
            self.updateSandboxOfficials()
            break
        }
    }

    /// Reset the view controller
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate = nil
        reachType = .home
    }

    // MARK: Segue
    
    /// Prepare to segue to show the details for an Official
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == HomeViewController.DETAILS_VIEW_SEGUE,
            let destination = segue.destination as? DetailsViewController,
            let indexPath = officialsTableView.indexPathForSelectedRow {
            
            // Deselect the row
            officialsTableView.deselectRow(at: indexPath, animated: false)
            
            // Set the selected Official
            destination.official = self.tableViewDataSource.getOfficial(
                at: indexPath.row)
        }
    }


    /// Updates the table view with the new officials
    /// Gets the user's current home address and checks if need to update the
    /// Officials. If needs to update, pulls the new Officials and updates
    /// the table view.
    private func updateHomeOfficials() {
        UsersDatabase.shared.getCurrentUserAddress {(address, error) in
            if let _ = error {
                // TODO: Handle error
            } else {
                if self.address == nil || self.address != address {
                    self.getOfficials(for: address!)
                }
            }
        }
    }
    
    /// Checks if a new sandbox address was selected. If a new address was
    /// selected, pulls the new Officials and updates the table view.
    private func updateSandboxOfficials() {
        if self.addressChanged {
            self.getOfficials(for: self.address!)
        }
    }
    
    /// Updates the officials for the given address.
    /// Scrapes the officials and reloads the table data if successfully pulls
    /// officials.
    ///
    /// - Parameter for:    the address to pull for
    private func getOfficials(for address: Address) {
        // Update the address
        self.address = address
        self.addressChanged = false
        
        // Scrape the new Officials
        OfficialScraper.getForAddress(
        address: address, apikey: civic_api_key) {(officials, error) in
            
            if error == nil {
                // Store the officials
                self.tableViewDataSource.officials = officials
            }
        }
    }

}
