//
//  MyEventsViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 5/5/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

// MyEventsViewController -> EventDetailsViewController
let EVENT_DETAILS_SEGUE = "eventDetailsSegue"

class MyEventsViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var eventsSearchBar: UISearchBar!

    var tableViewDelegate:EventsTableViewDelegate!
    var myEventsTableViewDataSource:EventsTableViewDataSource!
    var rsvpedTableViewDataSource:EventsTableViewDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set table view delegate
        tableViewDelegate = EventsTableViewDelegate()
        eventsTableView.delegate = tableViewDelegate

        // Set table view data source
        rsvpedTableViewDataSource = EventsTableViewDataSource(for: eventsTableView, with: .rsvp)
        myEventsTableViewDataSource = EventsTableViewDataSource(for: eventsTableView, with: .user)
        eventsTableView.dataSource = rsvpedTableViewDataSource

        eventsSearchBar.delegate = rsvpedTableViewDataSource

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if self.isMovingFromParent {
            AppState.removeUserEventsListener(myEventsTableViewDataSource)
        }
    }

    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            eventsTableView.dataSource = rsvpedTableViewDataSource
            eventsSearchBar.delegate = rsvpedTableViewDataSource
        } else {
            eventsTableView.dataSource = myEventsTableViewDataSource
            eventsSearchBar.delegate = myEventsTableViewDataSource
        }

        eventsTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == EVENT_DETAILS_SEGUE,
            let destination = segue.destination as? EventDetailsViewController,
            let eventIndex = eventsTableView.indexPathForSelectedRow?.row {
            if segmentedControl.selectedSegmentIndex == 0 {
                destination.event = rsvpedTableViewDataSource.events[eventIndex]
                destination.delegate = rsvpedTableViewDataSource
            } else {
                destination.event = myEventsTableViewDataSource.events[eventIndex]
                destination.delegate = myEventsTableViewDataSource
            }
        }
    }
}
