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

class EventListViewController: UIViewController,
                               UITableViewDelegate,
                               UITableViewDataSource {
    
    @IBOutlet weak var eventTableView: UITableView!
    
    var events:[Event] = []     // The events being displayed
    var address:Address?        // The current address for officials for events
    
    /// Set the table view delegate and datasource
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTableView.delegate = self
        eventTableView.dataSource = self
    }
    
    /// If the address or is nil, update the events being displayed
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.shouldUpdate() {
            self.address = AppState.sandboxAddress

            // Clear current events
            self.events.removeAll()

            // Pull the new events
            for official in AppState.homeOfficials {
                Event.allWith(official: official) {(events, error) in
                    if error == nil {
                        self.events += events
                        self.events.sort()
                        self.eventTableView.reloadData()
                    }
                }
            }
            
            // Update the table view
            self.eventTableView.reloadData()
        }
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
    
    /// Segue to the event details view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == EVENT_SEGUE_IDENTIFIER,
            let destination = segue.destination as? EventDetailsViewController,
            let eventIndex = eventTableView.indexPathForSelectedRow?.row {
            
            destination.event = events[eventIndex]
        }
    }
    
    /// Gets whether or not should update the Events being displayed
    ///
    /// - Returns: true if should update, false otherwise
    private func shouldUpdate() -> Bool {
        return self.events.isEmpty ||
            (AppState.sandboxAddress != nil &&
                self.address != AppState.sandboxAddress)
    }
    
    /// Filters the Events based on the given query
    ///
    /// - Parameter by:     the query to filter by
    ///
    /// - Returns: the Array of filtered Events
    private func filterEvents(by query:String) -> [Event] {
        return self.events.filter {(event) in event.matches(query)}
    }
}
