//
//  HomeViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 2/23/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import CoreLocation

let OFFICIAL_CELL_IDENTIFIER = "officialCell"
let DETAILS_VIEW_SEGUE = "detailsViewSegue"
let UNWIND_TO_CREATE_EVENT_SEGUE = "unwindToCreateEventViewController"

protocol OfficialSelectionDelegate {
    func didSelectOfficial(official: Official)
}

enum HomeViewControllerReachType {
    case home
    case map
    case event
}

class HomeViewController: UIViewController,
                          UITableViewDelegate,
                          UITableViewDataSource {

    // MARK: - Properties
    var reachType: HomeViewControllerReachType = .home
    var delegate: OfficialSelectionDelegate?
    var officials:[Official] = []
    var address:Address? {
        didSet {
            addressChanged = true
        }
    }
    var addressChanged:Bool = false
    
    // MARK: - Outlets
    @IBOutlet weak var officialsTableView: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        officialsTableView.delegate = self
        officialsTableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch reachType {
        case .home, .event:
            // Get the user's current home address and check if need to update
            // the officials
            UsersDatabase.shared.getCurrentUserAddress {(address, error) in
                if let _ = error {
                    // TODO: Handle error
                    print(error.debugDescription)
                } else {
                    if self.address == nil || self.address != address {
                        self.getOfficials(for: address!)
                    }
                }
            }
            break
        case .map:
            // Update the officials if the sandbox address has changed
            if self.addressChanged {
                self.getOfficials(for: self.address!)
            }
            break
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate = nil
        reachType = .home
    }

    // MARK: User Location
    
    /// Updates the officials for the given address.
    /// Scrapes the officials and reloads the table data if successfully pulls
    /// officials.
    ///
    /// - Parameter for:    the address to pull for
    func getOfficials(for address: Address) {
        // Update the address
        self.address = address
        self.addressChanged = false

        // Scrape the new Officials
        OfficialScraper.getForAddress(
            address: address, apikey: civic_api_key) {(officials, error) in
            
            if error == nil {
                // Store the officials
                self.officials = officials

                // Update the view
                self.updateTableData()
            }
        }
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.officials.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: OFFICIAL_CELL_IDENTIFIER,
            for: indexPath) as! OfficialCell
        
        cell.official = self.officials[indexPath.row]
        
        return cell
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
    private func updateTableData() {
        DispatchQueue.main.async {
            switch self.reachType {
            case .home, .event:
                self.navigationItem.title = "Home"
                break
            case .map:
                self.navigationItem.title = "\(self.address!.city), \(self.address!.state)"
                break
            }
            
            self.officialsTableView.reloadData()
        }
    }
}
