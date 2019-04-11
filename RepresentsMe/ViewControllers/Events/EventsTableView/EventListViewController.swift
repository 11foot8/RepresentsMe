//
//  EventListViewController.swift
//  RepresentsMe
//
//  Created by Varun Adiga on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit

let EVENT_SEGUE_IDENTIFIER = "eventSegueIdentifier"
let CREATE_EVENT_SEGUE_IDENTIFIER = "createEventSegue"

class EventListViewController: UIViewController,
                               UISearchBarDelegate,
                               EventListDelegate {
    
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var eventSearchBar: UISearchBar!
    
    var tableViewDelegate:EventsTableViewDelegate!
    var tableViewDataSource:EventsTableViewDataSource!
    
    var officials:[Official] = []   // The officials for the events
    var address:Address?            // The current address being displayed
    var events:[Event] = []         // All pulled events

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
        self.eventSearchBar.delegate = self
    }
    
    /// Update the events being displayed if the user's address changed
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Check if the user's home address has changed and update events if
        // it did change
        UsersDatabase.getCurrentUserAddress {(address, error) in
            if let _ = error {
                // TODO: Handle error
            } else {
                if self.shouldUpdate(address: address) {
                    self.getOfficials(for: address!)
                }
            }
        }
    }

    /// Gets the Officials for the given address and updates the Events
    ///
    /// - Parameter for:    the address to get for
    func getOfficials(for address: Address) {
        self.address = address
        OfficialScraper.getForAddress(
            address: address, apikey: civic_api_key) {(officials, error) in
                
            if error == nil {
                self.officials = officials
                self.getEvents()
            }
        }
    }

    /// Gets the Events for the current list of Officials and updates the
    /// events table view
    func getEvents() {
        // Clear current events
        self.tableViewDataSource.deleteAll()
        self.events.removeAll()

        // Pull the new events
        for official in self.officials {
            Event.allWith(official: official) {(events, error) in
                if error == nil {
                    // Add to the source
                    self.events += events
                    self.events.sort()
                    
                    // Add to the list being displayed
                    self.tableViewDataSource.add(
                        events: events,
                        filter: self.eventSearchBar.text ?? "")
                }
            }
        }
    }
    
    /// When the search text changes, filter the events
    func searchBar(_ searchBar:UISearchBar, textDidChange:String) {
        self.tableViewDataSource.set(events: self.events,
                                     filter: textDidChange)
    }
   
    /// Adds in a newly created event
    ///
    /// - Parameter event:  the Event that was created
    func eventCreatedDelegate(event: Event) {
        // Add to the events source
        events.append(event)
        events.sort()
        
        // Add to the displayed events
        self.tableViewDataSource.add(event: event,
                                     filter: self.eventSearchBar.text ?? "")
    }

    /// Reloads the table view when an event is updated
    func eventUpdatedDelegate() {
        self.tableViewDataSource.updateTableData()
    }

    /// Removes the given event from the Arrays of Events
    ///
    /// - Parameter event:  the Event to delete
    func eventDeletedDelegate(event:Event) {
        // Remove from the displayed events
        self.tableViewDataSource.delete(event: event)

        // Remove from the events source
        if let index = self.events.index(of: event) {
            self.events.remove(at: index)
        }
    }

    /// Segue to the event details view or the events create view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == EVENT_SEGUE_IDENTIFIER,
            let destination = segue.destination as? EventDetailsViewController,
            let eventIndex = eventTableView.indexPathForSelectedRow?.row {
            destination.event = self.tableViewDataSource.getEvent(
                at: eventIndex)
            destination.delegate = self
        } else if segue.identifier == CREATE_EVENT_SEGUE_IDENTIFIER,
            let destination = segue.destination as? CreateEventViewController {
            destination.delegate = self
        }
    }
    
    /// Gets whether or not should update the Events being displayed
    ///
    /// - Parameter address:    the user's set address
    ///
    /// - Returns: true if should update, false otherwise
    private func shouldUpdate(address:Address?) -> Bool {
        return self.address == nil || self.address != address
    }
}
