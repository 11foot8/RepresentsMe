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
let MY_EVENTS_SEGUE_IDENTIFIER = "myEventsSegue"


/// The view controller to show the list of Events for the user's home Address
class EventsListViewController: UIViewController {

    /// The modes avaliable for the events list view controller
    enum ReachType {
        case event      // Mode for showing the user's home Events
        case official   // Mode for showing Events for a selected Official
        case user       // Mode for shwoing Events for a selected User
    }

    // MARK: - Properties
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var eventSearchBar: UISearchBar!
    @IBOutlet weak var myEventsBarButton: UIBarButtonItem!

    var tableViewDelegate:EventsTableViewDelegate!
    var tableViewDataSource:EventsTableViewDataSource!

    var reachType:ReachType = .event
    var official:Official?
    var displayName:String?
    
    // MARK: - Lifecycle
    /// Set the table view delegate and datasource
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.navigationController?.topViewController == self && self.navigationController?.viewControllers.count ?? 0 > 1 {
            self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
        } else {
            myEventsBarButton.image = UIImage.fontAwesomeIcon(name: .idCardAlt,
                                                              style: .solid,
                                                              textColor: .blue,
                                                              size: CGSize(width: 24, height: 24))
        }

        // Set table view delegate
        tableViewDelegate = EventsTableViewDelegate()
        eventTableView.delegate = tableViewDelegate
        
        // Set table view data source
        switch reachType {
        case .event:
            tableViewDataSource = EventsTableViewDataSource(
                for: eventTableView, with: .event)
            break
        case .official:
            tableViewDataSource = EventsTableViewDataSource(
                for: eventTableView, with: .official)
            break
        case .user:
            tableViewDataSource = EventsTableViewDataSource(
                for: eventTableView, with: .user)
            break
        }
        eventTableView.dataSource = tableViewDataSource

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

        // Hide keyboard when tableView interacted with
        eventTableView.keyboardDismissMode = .interactive
        eventTableView.keyboardDismissMode = .onDrag

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

    @IBAction func myEventsButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: MY_EVENTS_SEGUE_IDENTIFIER, sender: self)
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
        } else if segue.identifier == MY_EVENTS_SEGUE_IDENTIFIER {
            AppState.userId = UsersDatabase.currentUserUID
        }
    }

    /// Hide keyboard when tapping out of SearchBar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
