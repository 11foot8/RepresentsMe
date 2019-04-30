//
//  EventsTableViewDataSource.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/10/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

let EVENT_CELL_IDENTIFIER = "eventCell"

/// The data source for the events table view.
/// Manages the Array of Events that are being displayed and handles adding,
/// removing, and setting the Events that are being shown
class EventsTableViewDataSource: NSObject,
                                 UITableViewDataSource,
                                 UISearchBarDelegate,
                                 EventListDelegate,
                                 EventsListener {

    var tableView:UITableView   // The table view this is the data source for
    var events:[Event] = []     // The Events being displayed
    var filter:String = ""      // The current filter for Events
    var reachType:EventsListViewController.ReachType = .event

    /// Initializes this data source for the given table view
    ///
    /// - Parameter for:    the table view this is the data source for
    /// - Parameter with:   the reach type of the table view, which determines the source
    init(for tableView:UITableView, with reachType:EventsListViewController.ReachType) {
        self.tableView = tableView
        super.init()

        self.reachType = reachType
        switch self.reachType {
        case .event:
            AppState.addHomeEventsListener(self)
            break
        case .official:
            AppState.addOfficialEventsListener(self)
            break
        case .user:
            AppState.addUserEventsListener(self)
            break
        }
        self.updateTableData()
    }
    
    /// Updates the Events table when new Events are received
    func appStateReceivedHomeEvents(events: [Event]) {
        self.updateTableData()
    }

    /// Updates the Events table when new Events are received
    func appStateReceivedOfficialEvents(events: [Event]) {
        self.updateTableData()
    }

    func appStateReceivedUserEvents(events: [Event]) {
        self.updateTableData()
    }
    
    /// Filters and updates the table data after an Event is created
    func eventCreatedDelegate(event: Event) {
        self.updateTableData()
    }
    
    /// Filters and updates the table data after an Event is updated
    func eventUpdatedDelegate(event: Event) {
        self.updateTableData()
    }
    
    /// Updates the table data after an Event is deleted
    func eventDeletedDelegate(event: Event) {
        self.updateTableData()
    }
    
    /// When the search text changes, filter the events
    func searchBar(_ searchBar:UISearchBar, textDidChange:String) {
        self.filter = textDidChange
        self.updateTableData()
    }

    /// The number of rows is the number of events
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    /// Sets the event for the given cell
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: EVENT_CELL_IDENTIFIER,
            for: indexPath) as! EventCell
        
        cell.event = self.events[indexPath.row]
        return cell
    }
    
    /// Filters the events and updates the table data
    private func updateTableData() {
        var eventList:[Event] = []
        switch reachType {
        case .event:
            eventList = AppState.homeEvents
            break
        case .official:
            eventList = AppState.officialEvents
            break
        case .user:
            eventList = AppState.userEvents
            break
        }

        // Filter the Events
        self.events = eventList.filter {(event) in
            event.matches(self.filter)
        }
        
        // Update the table data
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
