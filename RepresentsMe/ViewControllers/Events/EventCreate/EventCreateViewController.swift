//
//  EventCreateViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/8/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit
import EventKit

// EventCreateViewController -> OfficialsListViewController
let SELECT_OFFICIAL_SEGUE = "selectOfficialSegue"
// EventCreateViewController -> MapViewController
let SELECT_LOCATION_SEGUE = "selectLocationSegue"
// EventCreateViewController -> DatePopoverViewController
let DATE_POPOVER_SEGUE = "datePopoverSegue"
// EventCreateViewController -> EventImportViewController
let IMPORT_EVENT_SEGUE = "importEventSegue"

/// The view controller to handle creating and updating Events
class EventCreateViewController: UIViewController,
                                 OfficialSelectionDelegate,
                                 LocationSelectionDelegate,
                                 DatePopoverViewControllerDelegate,
                                 EventImportListener {

    // MARK: - Properties
    var event: Event?                               // The Event if editing
    var selectedDate: Date?                         // The selected date
    var selectedOfficial: Official?                 // The selected Official
    var selectedLocation: CLLocationCoordinate2D?   // The selected location
    var delegate:EventListDelegate?                 // The delegate to update
    var mapViewAnnotation:MKAnnotation?             // The dropped pin on the mapview
    let regionInMeters:CLLocationDistance = 7500

    // MARK: - Outlets
    @IBOutlet weak var eventOfficialCardView: OfficialCardView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var selectOfficialButton: UIButton!
    @IBOutlet weak var selectLocationButton: UIButton!
    @IBOutlet weak var selectDateButton: UIButton!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var selectedLocationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var importEventBarButton: UIBarButtonItem!

    // MARK: - Lifecycle
    /// Sets up the view for the Event if editing an Event
    override func viewDidLoad() {
        super.viewDidLoad()

        // If editing an Event, setup for that Event
        if let event = self.event {
            self.setupFor(event: event)
        }

        self.setupMapView()
        self.set(date: Date.init())

        importEventBarButton.image = UIImage.fontAwesomeIcon(
            name: .fileUpload,
            style: .solid,
            textColor: .blue,
            size: CGSize(width: 24, height: 24))
    }

    // MARK: - Actions
    /// Creates or updates the Event when the save button is pressed.
    /// If successfully saves, segues back a view controller
    @IBAction func saveTapped(_ sender: Any) {
        // Ensure selected attributes are valid
        let description = ""            // TODO: fill in
        guard let official = selectedOfficial else {return}
        guard let location = selectedLocation else {return}
        guard let date = selectedDate else {return}
        let name = self.eventNameTextField.text!
        guard !name.isEmpty else {return}

        if event != nil {
            // Editing an Event, update it
            self.updateEvent(name: name,
                             official: official,
                             location: location,
                             date: date)
        } else {
            // Not editing an Event, create a new Event
            self.createEvent(name: name,
                             description: description,
                             official: official,
                             location: location,
                             date: date)
        }
    }

    /// Discard changes and segue back a view controller
    @IBAction func cancelTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // Hide keyboard when select officials is tapped
    @IBAction func selectOfficialTouchUp(_ sender: Any) {
        self.view.endEditing(true)
    }

    // Hide keyboard when edit date is tapped
    @IBAction func editDateTouchUp(_ sender: Any) {
        self.view.endEditing(true)
    }

    // Hide keyboard when edit location is tapped
    @IBAction func editLocationTouchUp(_ sender: Any) {
        self.view.endEditing(true)
    }

    /// Prepare for segues to select the Official, location, and date
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SELECT_OFFICIAL_SEGUE) {
            // Seguing to select an Official
            let destination = segue.destination as! OfficialsListViewController
            destination.reachType = .event
            destination.delegate = self
        } else if segue.identifier == SELECT_LOCATION_SEGUE {
            // Seguing to select a location
            let destination = segue.destination as! MapViewController
            destination.reachType = .event
            destination.delegate = self
        } else if segue.identifier == DATE_POPOVER_SEGUE {
            // Seguing to select a date
            let destination = segue.destination as! DatePopoverViewController
            destination.setup(in: self.view)
            destination.delegate = self
        } else if segue.identifier == IMPORT_EVENT_SEGUE {
            let destination = segue.destination as! EventImportViewController
            destination.listener = self
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
    
    /// When an event is imported populate as many fields as possible with it
    func eventSelected(_ event: EKEvent) {
        self.eventNameTextField.text = event.title
        self.set(date: event.startDate)
        
        if let location = event.location {
            GeocoderWrapper.geocodeAddressString(location) {(placemark) in
                let address = Address(with: placemark)
                self.set(location: placemark.location!.coordinate,
                         address: address)
            }
        }
    }

    func setupLabels() {
        self.selectedDateLabel.layer.cornerRadius = 8.0
        self.selectedDateLabel.clipsToBounds = true
        self.selectedDateLabel.layer.borderColor = UIColor.lightGray.cgColor
        self.selectedDateLabel.layer.borderWidth = 1.0

        self.selectedLocationLabel.layer.cornerRadius = 8.0
        self.selectedLocationLabel.clipsToBounds = true
        self.selectedLocationLabel.layer.borderColor = UIColor.lightGray.cgColor
        self.selectedLocationLabel.layer.borderWidth = 1.0

    }
    /// Sets up mapView
    func setupMapView() {
        self.mapView.isScrollEnabled = false
        self.mapView.layer.cornerRadius = 10
        self.mapView.clipsToBounds = true
        self.mapView.layer.borderColor = UIColor.lightGray.cgColor
        self.mapView.layer.borderWidth = 1.0
    }

    func setMapViewLocation(location: CLLocationCoordinate2D,
                            address: Address) {
        if let annotation = self.mapViewAnnotation {
            mapView.removeAnnotation(annotation)
        }
        self.mapViewAnnotation = DroppedPin(title: address.streetAddress, locationName: address.addressCityState(), discipline: "", coordinate: location)
        self.mapView.addAnnotation(self.mapViewAnnotation!)
        let region = MKCoordinateRegion(center: location,
                                        latitudinalMeters: regionInMeters,
                                        longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: false)
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
        selectedLocationLabel.text = event.address.description
        
        // Set the date
        self.set(date: event.startDate)
        selectedDateLabel.text = event.formattedDate
    }

    /// Sets the Official for the Event
    ///
    /// - Parameter official:   the Official to set
    private func set(official:Official?) {
        if let official = official {
            selectedOfficial = official
            eventOfficialCardView.set(official: official)
        }
    }
    
    /// Sets the location for the Event
    ///
    /// - Parameter location:   the coordinates for the Event
    /// - Parameter address:    the Address for the Event
    private func set(location:CLLocationCoordinate2D, address:Address) {
        selectedLocation = location
        selectedLocationLabel.text = address.fullMultilineAddress()
        self.setMapViewLocation(location: location, address: address)
    }
    
    /// Sets the date for the Event
    ///
    /// - Parameter date:   the Date for the Event
    private func set(date:Date) {
        selectedDate = date
        
        // Format the date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, YYYY h:mm a"
        selectedDateLabel.text = formatter.string(from: date)
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
            event.startDate = date
            event.official = official
    
            // Save the changes
            event.save {(event, error) in
                if (error != nil) {
                    // TODO: handle error
                } else {
                    self.delegate?.eventUpdatedDelegate(event: event!)
    
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
    /// - Parameter name:           the name for the Event
    /// - Parameter description:    the description for the Event
    /// - Parameter official:       the Official for the Event
    /// - Parameter location:       the location for the Event
    /// - Parameter date:           the date for the Event
    private func createEvent(name:String,
                             description:String,
                             official:Official,
                             location:CLLocationCoordinate2D,
                             date:Date) {
        Event.create(name: name,
                     owner: UsersDatabase.currentUserUID!,
                     description: description,
                     location: location,
                     startDte: date,
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
