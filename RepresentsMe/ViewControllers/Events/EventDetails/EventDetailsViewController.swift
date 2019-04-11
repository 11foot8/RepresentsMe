//
//  EventDetailsViewController.swift
//  RepresentsMe
//
//  Created by Varun Adiga on 4/9/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// EventDetailsViewController -> CreateEventViewController
let EDIT_EVENT_SEGUE = "editEventSegue"

/// The view controller to display the details for an Event and allow the
/// owner of the Event to edit and delete the Event.
class EventDetailsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var officialNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteEventButton: UIButton!

    var event:Event?                    // The Event to display
    var delegate:EventListDelegate?     // The delegate to update

    /// Sets up the view for the Event to display
    override func viewWillAppear(_ animated: Bool) {
        if event != nil {
            // Set the labels
            self.setLabels()

            // Set the photo
            self.setPhoto()

            // Center the map on the location for the event
            self.setupMapView()

            // Set whether or not the user can edit the event
            self.setEditable()
        }
    }

    /// Segue to edit the Event
    @IBAction func editButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: EDIT_EVENT_SEGUE, sender: self)
    }

    /// Delete the Event and segue back to the Events list
    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.event?.delete(completion: {(event, error) in
            if (error != nil) {
                // TODO: handle error
            } else {
                self.delegate?.eventDeletedDelegate(event: event!)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }

    /// Prepare to segue to edit the Event
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == EDIT_EVENT_SEGUE {
            let destination = segue.destination as! CreateEventViewController
            destination.event = event
            destination.delegate = delegate
        }
    }
    
    /// Sets the labels for the Event
    private func setLabels() {
        if let event = self.event {
            eventNameLabel.text = event.name
            officialNameLabel.text = event.official?.name
            eventDateLabel.text = event.formattedDate
    
            // Set the location
            self.eventLocationLabel.text = ""
            GeocoderWrapper.reverseGeocodeCoordinates(event.location) {(address) in
                self.eventLocationLabel.text = address.description
            }
        }
    }
    
    /// Sets the photo for the Event
    private func setPhoto() {
        if let event = self.event, let photo = event.official?.photo {
            portraitImageView.image = photo
        }
    }
    
    /// Centers the map on the location for the Event
    private func setupMapView() {
        if let event = self.event {
            let span = MKCoordinateSpan(latitudeDelta: 0.1,
                                        longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: event.location, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    /// Sets up the edit views based on whether or not the user is allowed to
    /// edit the Event
    private func setEditable() {
        if let event = self.event {
            if (UsersDatabase.currentUserUID == event.owner) {
                // User owns the event, let them edit it
                editButton.isEnabled = true
                editButton.title = "Edit"
                deleteEventButton.isEnabled = true
                deleteEventButton.isHidden = false
            } else {
                // User does not own the event, do not let them edit it
                editButton.isEnabled = false
                deleteEventButton.isHidden = true
                deleteEventButton.isEnabled = false
            }
        }
    }
}
