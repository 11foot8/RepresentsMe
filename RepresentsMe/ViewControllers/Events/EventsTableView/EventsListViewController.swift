//
//  EventsListViewController.swift
//  RepresentsMe
//
//  Created by Varun Adiga on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit

// EventsListViewController -> EventDetailsViewController
let EVENT_SEGUE_IDENTIFIER = "eventSegueIdentifier"
// EventsListViewController -> EventCreateViewController
let CREATE_EVENT_SEGUE_IDENTIFIER = "createEventSegue"

/// The view controller to show the list of Events for the user's home Address
class EventsListViewController: UIViewController {

    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var eventSearchBar: UISearchBar!
    
    var tableViewDelegate:EventsTableViewDelegate!
    var tableViewDataSource:EventsTableViewDataSource!
    
    /// Set the table view delegate and datasource
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table view delegate
        self.tableViewDelegate = EventsTableViewDelegate()
        self.eventTableView.delegate = self.tableViewDelegate
        
        // Set table view data source
        self.tableViewDataSource = EventsTableViewDataSource(
            for: self.eventTableView)
        self.eventTableView.dataSource = self.tableViewDataSource
        
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
