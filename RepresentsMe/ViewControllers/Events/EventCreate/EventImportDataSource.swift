//
//  EventImportDataSource.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/29/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import EventKit

let IMPORT_CELL_IDENTIFIER = "eventImportCell"

/// The data source for the table view of events the user can choose to
/// import from.
class EventImportDataSource: NSObject, UITableViewDataSource {
    
    var events:[EKEvent] = []
    var tableView:UITableView
    
    /// Load in the events to display
    init(for tableView:UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = self
        
        // If the authorization status for calendar access isn't authorized,
        // request access again and then export the event. Otherwise, just
        // import the events
        let eventStore = EKEventStore()
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event) {(granted, error) in
                if granted {
                    self.importEvents(eventStore)
                }
            }
        } else {
            self.importEvents(eventStore)
        }
    }
    
    /// Number of rows is the number of events
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    /// Set the event for the given cell
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: IMPORT_CELL_IDENTIFIER,
            for: indexPath) as! EventImportCell
        
        cell.event = self.events[indexPath.row]
        return cell
    }
    
    /// Imports the events from the user's calendar
    ///
    /// - Parameter eventStore:     the EKEventStore to use to import
    private func importEvents(_ eventStore:EKEventStore) {
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            if calendar.title != "US Holidays" &&
                calendar.title != "Birthdays" {
                // Only get events up to one month from now
                let now = Date()
                let oneMonthAfter = Date(timeIntervalSinceNow: +30*24*3600)
                let predicate = eventStore.predicateForEvents(
                    withStart: now,
                    end: oneMonthAfter,
                    calendars: [calendar])
                
                // Add to list of events
                self.events += eventStore.events(matching: predicate)
            }
        }
        
        self.tableView.reloadData()
    }
}
