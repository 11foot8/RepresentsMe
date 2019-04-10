//
//  EventListViewController.swift
//  RepresentsMe
//
//  Created by Varun Adiga on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit

let EVENT_CELL_IDENTIFIER = "eventCell"
let EVENT_SEGUE_IDENTIFIER = "eventSegueIdentifier"
let CREATE_EVENT_SEGUE_IDENTIFIER = "createEventSegue"

class EventListViewController: UIViewController,
                               UITableViewDelegate,
                               UITableViewDataSource,
                               UISearchBarDelegate,
                               CreateEventsDelegate {
    
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var eventSearchBar: UISearchBar!
    
    var officials:[Official] = []   // The officials for the events
    var address:Address?            // The current address being displayed
    var eventsSource:[Event] = []   // All pulled events
    var events:[Event] = []         // The events being displayed

    /// Set the table view delegate and datasource
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTableView.delegate = self
        eventTableView.dataSource = self
        eventSearchBar.delegate = self
    }
    
    /// Update the events being displayed if the user's address changed
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Check if the user's home address has changed and update events if
        // it did change
        UsersDatabase.shared.getCurrentUserAddress {(address, error) in
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
        self.events.removeAll()
        self.eventsSource.removeAll()

        // Pull the new events
        for official in self.officials {
            Event.allWith(official: official) {(events, error) in
                if error == nil {
                    // Add to the source
                    self.eventsSource += events
                    self.eventsSource.sort()
                    
                    // Add to the list being displayed
                    self.events += events.filter {(event) in
                        event.matches(self.eventSearchBar.text ?? "")
                    }
                    self.events.sort()

                    // Update the table view
                    self.updateTableData()
                }
            }
        }

        // Update the table view
        self.updateTableData()
    }
    
    /// When the search text changes, filter the events
    func searchBar(_ searchBar:UISearchBar, textDidChange:String) {
        self.events = self.filterEvents(by: textDidChange)
        self.eventTableView.reloadData()
    }
    
    // MARK: UITableViewDelegate
    
    /// The number of rows is the number of events
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    /// Sets the event for the given cell
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: EVENT_CELL_IDENTIFIER,
            for: indexPath) as! EventCell
        cell.event = events[indexPath.row]
        return cell
    }
    
    /// Deselect a cell after it is selected
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: Segue
    
    func eventCreatedDelegate(event: Event) {
        eventsSource.append(event)
        eventsSource.sort()
        if event.matches(eventSearchBar.text!) {
            events.append(event)
            events.sort()
            eventTableView.reloadData()
        }
    }

    func eventUpdatedDelegate(event: Event) {
        eventTableView.reloadData()
    }

    func eventDeletedDelegate(event: Event) {
        events.removeAll { (tableEvent: Event) -> Bool in
            tableEvent == event
        }

        eventsSource.removeAll { (tableEvent: Event) -> Bool in
            tableEvent == event
        }
        
        eventTableView.reloadData()
    }

    /// Segue to the event details view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == EVENT_SEGUE_IDENTIFIER,
            let destination = segue.destination as? EventDetailsViewController,
            let eventIndex = eventTableView.indexPathForSelectedRow?.row {
            destination.event = events[eventIndex]
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
    
    /// Filters the Events based on the given query
    ///
    /// - Parameter by:     the query to filter by
    ///
    /// - Returns: the Array of filtered Events
    private func filterEvents(by query:String) -> [Event] {
        return self.eventsSource.filter {(event) in event.matches(query)}
    }
    
    /// Updates the event table view
    private func updateTableData() {
        DispatchQueue.main.async {
            self.eventTableView.reloadData()
        }
    }
}
