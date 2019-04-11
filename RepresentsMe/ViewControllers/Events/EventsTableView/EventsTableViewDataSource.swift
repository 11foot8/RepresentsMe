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
class EventsTableViewDataSource: NSObject, UITableViewDataSource {
    
    var tableView:UITableView   // The table view this is the data source for
    var events:[Event] = []     // The events being displayed
    
    /// Initializes this data source for the given table view
    ///
    /// - Parameter for:    the table view this is the data source for
    init(for tableView:UITableView) {
        self.tableView = tableView
    }

    /// Adds a single event
    ///
    /// - Parameter event:      the Event to add
    /// - Parameter filter:     the filter to check event against
    func add(event:Event, filter:String) {
        if event.matches(filter) {
            self.events.append(event)
            self.events.sort()
            self.updateTableData()
        }
    }

    /// Adds an Array of Events
    ///
    /// - Parameter events:     the Events to add
    /// - Parameter filter:     the filter to check each Event against
    func add(events:[Event], filter:String) {
        self.events += events.filter {(event) in event.matches(filter)}
        self.events.sort()
        self.updateTableData()
    }
    
    /// Sets the events to the given events that match the given filter
    ///
    /// - Parameter events:     the Events to set
    /// - Parameter filter:     the filter to check each Event against
    func set(events:[Event], filter:String) {
        self.events = events.filter {(event) in event.matches(filter)}
        self.updateTableData()
    }
    
    /// Deletes the given Event
    ///
    /// - Parameter event:  the event to delete
    func delete(event:Event) {
        if let index = self.events.index(of: event) {
            self.events.remove(at: index)
            self.updateTableData()
        }
    }
    
    /// Deletes all Events
    func deleteAll() {
        self.events.removeAll()
        self.updateTableData()
    }
    
    /// Gets the Event at the given index
    ///
    /// - Parameter at:     the index
    ///
    /// - Returns: the Event
    func getEvent(at index:Int) -> Event {
        return self.events[index]
    }
    
    /// Updates the event table view
    func updateTableData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
}
