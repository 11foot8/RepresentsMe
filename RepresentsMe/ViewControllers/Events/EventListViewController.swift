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
    
    var eventsSource:[Event] = []
    var events:[Event] = []     // The events being displayed
    var address:Address?        // The current address for officials for events
    var previousAddress:Address?
    
    /// Set the table view delegate and datasource
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTableView.delegate = self
        eventTableView.dataSource = self
        eventSearchBar.delegate = self
    }
    
    /// If the address or is nil, update the events being displayed
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UsersDatabase.getCurrentUserAddress { (address, error) in
            if let _ = error {
                // TODO: Handle error
            } else {
                if self.previousAddress == nil || self.previousAddress != address {
                    self.getOfficials(for: address!)
                }
            }
        }
    }

    func getOfficials(for address: Address) {
        previousAddress = address
        OfficialScraper.getForAddress(address: address, apikey: civic_api_key) {
            (officialList: [Official]?, error: ParserError?) in
            if error == nil, let officialList = officialList {
                AppState.homeOfficials = officialList
                self.reloadEvents()
            }
        }
    }

    func reloadEvents() {
        // Clear current events
        self.events.removeAll()
        self.eventsSource.removeAll()

        // Pull the new events
        for official in AppState.homeOfficials {
            Event.allWith(official: official) {(events, error) in
                if error == nil {
                    self.eventsSource += events
                    self.eventsSource.sort()
                    self.events += events
                    self.events.sort()

                    DispatchQueue.main.async {
                        self.eventTableView.reloadData()
                    }
                }
            }
        }

        // Update the table view
        DispatchQueue.main.async {
            self.eventTableView.reloadData()
        }
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
    /// - Returns: true if should update, false otherwise
    private func shouldUpdate() -> Bool {
        return self.events.isEmpty
    }
    
    /// Filters the Events based on the given query
    ///
    /// - Parameter by:     the query to filter by
    ///
    /// - Returns: the Array of filtered Events
    private func filterEvents(by query:String) -> [Event] {
        return self.eventsSource.filter {(event) in event.matches(query)}
    }
}
