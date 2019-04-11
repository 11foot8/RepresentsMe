//
//  OfficialsListViewController.swift
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
class OfficialsListViewController: UIViewController, AppStateListener {
    
    static let DETAILS_VIEW_SEGUE = "detailsViewSegue"

    /// The modes avaliable for the home view controller
    enum ReachType {
        case home       // Mode for showing the user's home Officials
        case map        // Mode for showing Officials from the sandbox mode
        case event      // Mode for showing Officials to select for an Event
    }

    // MARK: - Properties
    
    // The table view delegate and data source
    var tableViewDataSource:OfficialsTableViewDataSource!
    var tableViewDelegate:OfficialsTableViewDelegate!
    
    // Properties
    var reachType:ReachType = .home
    var delegate:OfficialSelectionDelegate?

    // MARK: - Outlets
    
    @IBOutlet weak var officialsTableView: UITableView!

    // MARK: - Lifecycle
    
    /// Set the table view delegate and data source
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the data source
        self.tableViewDataSource = OfficialsTableViewDataSource(for: self)
        officialsTableView.dataSource = self.tableViewDataSource
        
        // Set the delegate
        self.tableViewDelegate = OfficialsTableViewDelegate(for: self)
        officialsTableView.delegate = self.tableViewDelegate
        
        // Add as a listener
        switch self.reachType {
        case .home, .event:
            AppState.addHomeAddressListener(listener: self)
        case .map:
            AppState.addSandboxAddressListener(listener: self)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (self.isMovingFromParent) {
            switch self.reachType {
            case .home, .event:
                AppState.removeHomeAddressListener(listener: self)
                break
            case .map:
                AppState.removeSandboxAddressListener(listener: self)
                break
            }
        }
    }
    
    func appStateReceivedHomeOfficials(officials: [Official]) {
        DispatchQueue.main.async {
            self.navigationItem.title = "Home"
            self.officialsTableView.reloadData()
        }
    }
    
    func appStateReceivedSandboxOfficials(officials: [Official]) {
        DispatchQueue.main.async {
            self.navigationItem.title = "\(AppState.sandboxAddress!.city), \(AppState.sandboxAddress!.state)"
            self.officialsTableView.reloadData()
        }
    }

    // MARK: Segue
    
    /// Prepare to segue to show the details for an Official
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == OfficialsListViewController.DETAILS_VIEW_SEGUE,
            let destination = segue.destination as? OfficialDetailsViewController,
            let indexPath = officialsTableView.indexPathForSelectedRow {
            
            // Deselect the row
            officialsTableView.deselectRow(at: indexPath, animated: false)
            
            // Set the selected Official
            switch self.reachType {
            case .home, .event:
                destination.official = AppState.homeOfficials[indexPath.row]
            case .map:
                destination.official = AppState.sandboxOfficials[indexPath.row]
            }
        }
    }
}
