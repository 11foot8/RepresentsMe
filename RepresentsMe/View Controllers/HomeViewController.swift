//
//  HomeViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 2/23/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import CoreLocation

let DETAILS_VIEW_SEGUE = "detailsViewSegue"
let UNWIND_TO_CREATE_EVENT_SEGUE = "unwindToCreateEventViewController"

protocol OfficialSelectionDelegate {
    func didSelectOfficial(official: Official)
}

class HomeViewController: UIViewController,
                          UITableViewDelegate {

    /// The modes avaliable for the home view controller
    enum ReachType {
        case home       // Mode for showing the user's home Officials
        case map        // Mode for showing Officials from the sandbox mode
        case event      // Mode for showing Officials to select for an Event
    }

    // MARK: - Properties
    
    var tableViewDataSource:HomeTableViewDataSource!
    
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
        officialsTableView.delegate = self
        
        // Set the data source
        self.tableViewDataSource = HomeTableViewDataSource(for: self)
        officialsTableView.dataSource = self.tableViewDataSource
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch reachType {
        case .home, .map:
            performSegue(withIdentifier: DETAILS_VIEW_SEGUE, sender: self)
            break
        case .event:
            delegate?.didSelectOfficial(official: self.officials[indexPath.row])
            navigationController?.popViewController(animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DETAILS_VIEW_SEGUE,
            let destination = segue.destination as? DetailsViewController,
            let indexPath = officialsTableView.indexPathForSelectedRow {
            
            officialsTableView.deselectRow(at: indexPath, animated: false)
            destination.official = self.officials[indexPath.row]
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
