//
//  EventsListViewController.swift
//  RepresentsMe
//
//  Created by Varun Adiga on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit
import Firebase

// EventsListViewController -> EventDetailsViewController
let EVENT_SEGUE_IDENTIFIER = "eventSegueIdentifier"
// EventsListViewController -> EventCreateViewController
let CREATE_EVENT_SEGUE_IDENTIFIER = "createEventSegue"

/// The view controller to show the list of Events for the user's home Address
class EventsListViewController: UIViewController {

    /// The modes avaliable for the events list view controller
    enum ReachType {
        case event      // Mode for showing the user's home Events
        case official   // Mode for showing Events for a selected Official
        case user       // Mode for shwoing Events for a selected User
    }

    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var eventSearchBar: UISearchBar!
    @IBOutlet weak var myEventsBarButton: UIBarButtonItem!

    var tableViewDelegate:EventsTableViewDelegate!
    var tableViewDataSource:EventsTableViewDataSource!

    var reachType:ReachType = .event
    var official:Official?
    var displayName:String?
    
    /// Set the table view delegate and datasource
    override func viewDidLoad() {
        super.viewDidLoad()

        myEventsBarButton.image = UIImage.fontAwesomeIcon(name: .idCardAlt,
                                                          style: .solid,
                                                          textColor: .blue,
                                                          size: CGSize(width: 24, height: 24))
        
        
        // Set table view delegate
        self.tableViewDelegate = EventsTableViewDelegate()
        self.eventTableView.delegate = self.tableViewDelegate
        
        // Set table view data source
        self.tableViewDataSource = EventsTableViewDataSource(
            for: self.eventTableView, with: reachType)
        self.eventTableView.dataSource = self.tableViewDataSource

        // Set navigation bar title
        switch reachType {
        case .event:
            self.navigationItem.title = "Home Events"
            break
        case .official:
            self.navigationItem.title = "\(official!.name)'s Events"
            break
        case .user:
            if let displayName = displayName {
                self.navigationItem.title = "\(displayName)'s Events"
            } else {
                self.navigationItem.title = ""
            }
            break
        }
        
        // Set search bar delegate
        self.eventSearchBar.delegate = self.tableViewDataSource
    }
    
    /// Update the events being displayed if the user's address changed
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure the navigation bar is shown
        self.navigationController?.setNavigationBarHidden(false,
                                                          animated: false)
    }

    /// Remove as a listener if moving from parent
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if self.isMovingFromParent {
            switch self.reachType {
            case .event:
                AppState.removeHomeEventsListener(self.tableViewDataSource)
                break
            case .official:
                AppState.removeOfficialEventsListener(self.tableViewDataSource)
                break
            case .user:
                AppState.removeUserEventsListener(self.tableViewDataSource)
                break
            }
        }
    }

    /// Segue to the event details view or the events create view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == EVENT_SEGUE_IDENTIFIER,
            let destination = segue.destination as? EventDetailsViewController,
            let eventIndex = eventTableView.indexPathForSelectedRow?.row {
            destination.event = self.tableViewDataSource.events[eventIndex]
            destination.delegate = self.tableViewDataSource
        } else if segue.identifier == CREATE_EVENT_SEGUE_IDENTIFIER,
            let destination = segue.destination as? EventCreateViewController {
            destination.delegate = self.tableViewDataSource
        }
    }
}
