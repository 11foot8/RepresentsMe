//
//  EventCreateViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/8/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit

// EventCreateViewController -> OfficialsListViewController
let SELECT_OFFICIAL_SEGUE = "selectOfficialSegue"
// EventCreateViewController -> MapViewController
let SELECT_LOCATION_SEGUE = "selectLocationSegue"
// EventCreateViewController -> DatePopoverViewController
let DATE_POPOVER_SEGUE = "datePopoverSegue"

/// The view controller to handle creating and updating Events
class EventCreateViewController: UIViewController,
                                 UIPopoverPresentationControllerDelegate,
                                 OfficialSelectionDelegate,
                                 LocationSelectionDelegate,
                                 DatePopoverViewControllerDelegate {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var selectOfficialButton: UIButton!
    @IBOutlet weak var selectLocationButton: UIButton!
    @IBOutlet weak var selectDateButton: UIButton!

    var event: Event?                               // The Event if editing
    var selectedDate: Date?                         // The selected date
    var selectedOfficial: Official?                 // The selected Official
    var selectedLocation: CLLocationCoordinate2D?   // The selected location
    var delegate:EventListDelegate?                 // The delegate to update

    /// Sets up the view for the Event if editing an Event
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the image view
        self.setupImageView()

        // If editing an Event, setup for that Event
        if let event = self.event {
            self.setupFor(event: event)
        }
    }

    /// Update the views when an Official is selected.
    /// Implements OfficialSelectionDelegate
    ///
    /// - Parameter official:   the Official that was selected
    func didSelectOfficial(official: Official) {
        self.set(official: official)
    }

    /// Update the views when a location is selected
    /// Implements LocationSelectionDelegate
    ///
    /// - Parameter location:   the selected location
    /// - Parameter address:    the selected Address
    func didSelectLocation(location: CLLocationCoordinate2D,
                           address: Address) {
        self.set(location: location, address: address)
    }

    /// Update the views when a date is selected
    /// Implements DatePopoverViewControllerDelegate
    ///
    /// - Parameter date:   the selected date
    func didSelectDate(date: Date) {
        self.set(date: date)
    }

    /// Creates or updates the Event when the save button is pressed.
    /// If successfully saves, segues back a view controller
    @IBAction func saveTapped(_ sender: Any) {
        // Ensure selected attributes are valid
        guard let official = selectedOfficial else {return}
        guard let location = selectedLocation else {return}
        guard let date = selectedDate else {return}
        let name = self.eventNameTextField.text!

        if event != nil {
            // Editing an Event, update it
            self.updateEvent(name: name,
                             official: official,
                             location: location,
                             date: date)
        } else {
            // Not editing an Event, create a new Event
            self.createEvent(name: name,
                             official: official,
                             location: location,
                             date: date)
        }
    }

    /// Discard changes and segue back a view controller
    @IBAction func cancelTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    /// UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(
        for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    /// Prepare for segues to select the Official, location, and date
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SELECT_OFFICIAL_SEGUE) {
            // Seguing to select an Official
            let destination = segue.destination as! OfficialsListViewController
            destination.reachType = .event
            destination.delegate = self
        } else if (segue.identifier == SELECT_LOCATION_SEGUE) {
            // Seguing to select a location
            let destination = segue.destination as! MapViewController
            destination.reachType = .event
            destination.delegate = self
        } else if (segue.identifier == DATE_POPOVER_SEGUE) {
            // Seguing to select a date
            let destination = segue.destination as! DatePopoverViewController
            destination.setup(parent: self, view: self.view)
            destination.delegate = self
        }
    }

    /// Sets up the image view
    private func setupImageView() {
        eventImageView.layer.cornerRadius = 5.0
        eventImageView.clipsToBounds = true
        eventImageView.image = DEFAULT_NOT_LOADED
    }
    
    /// Sets up the views for the given Event
    ///
    /// - Parameter event:  the Event to setup for
    private func setupFor(event:Event) {
        // Set the name of the Event
        eventNameTextField.text = event.name
        
        // Set the official
        self.set(official: event.official)

        // Set the location
        selectLocationButton.setTitle("", for: .normal)
        GeocoderWrapper.reverseGeocodeCoordinates(
            event.location) {(address: Address) in
            self.set(location: event.location, address: address)
        }
        
        // Set the date
        self.set(date: event.date)
        selectDateButton.setTitle(event.formattedDate, for: .normal)
    }
    
    /// Sets the Official for the Event
    ///
    /// - Parameter official:   the Official to set
    private func set(official:Official?) {
        if let official = official {
            selectedOfficial = official
            eventImageView.image = official.photo
            selectOfficialButton.setTitle(official.name, for: .normal)
        }
    }
    
    /// Sets the location for the Event
    ///
    /// - Parameter location:   the coordinates for the Event
    /// - Parameter address:    the Address for the Event
    private func set(location:CLLocationCoordinate2D, address:Address) {
        selectedLocation = location
        selectLocationButton.setTitle(address.addressLine1(),
                                      for: .normal)
    }
    
    /// Sets the date for the Event
    ///
    /// - Parameter date:   the Date for the Event
    private func set(date:Date) {
        selectedDate = date
        
        // Format the date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, h:mm a"
        selectDateButton.setTitle(formatter.string(from: date), for: .normal)
    }
    
    /// Updates the Event.
    /// Segues back a view controller if successfully updates
    ///
    /// - Parameter name:       the new name
    /// - Parameter official:   the new Official
    /// - Parameter location:   the new location
    /// - Parameter date:       the new date
    private func updateEvent(name:String,
                             official:Official,
                             location:CLLocationCoordinate2D,
                             date:Date) {
        if let event = event {
            event.name = name
            event.location = location
            event.date = date
            event.official = official
    
            // Save the changes
            event.save {(event, error) in
                if (error != nil) {
                    // TODO: handle error
                } else {
                    self.delegate?.eventUpdatedDelegate()
    
                    // Navigate back
                    self.navigationController?.popViewController(
                        animated: true)
                }
            }
        }
    }
    
    /// Creates a new Event.
    /// Segues back a view controller if successfully creates
    ///
    /// - Parameter name:       the name for the Event
    /// - Parameter official:   the Official for the Event
    /// - Parameter location:   the location for the Event
    /// - Parameter date:       the date for the Event
    private func createEvent(name:String,
                             official:Official,
                             location:CLLocationCoordinate2D,
                             date:Date) {
        Event.create(name: name,
                     owner: UsersDatabase.currentUserUID!,
                     location: location,
                     date: date,
                     official: official) {(event, error) in
            if (error != nil) {
                // TODO: handle error
            } else {
                self.delegate?.eventCreatedDelegate(event: event!)

                // Navigate back
                self.navigationController?.popViewController(
                    animated: true)
            }
        }
    }
}
