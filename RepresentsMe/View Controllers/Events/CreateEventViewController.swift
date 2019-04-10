//
//  CreateEventViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/8/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit

let SELECT_OFFICIAL_SEGUE = "selectOfficialSegue"
let SELECT_LOCATION_SEGUE = "selectLocationSegue"
let DATE_POPOVER_SEGUE = "datePopoverSegue"

class CreateEventViewController: UIViewController,
                                 UIPopoverPresentationControllerDelegate,
                                 OfficialSelectionDelegate,
                                 LocationSelectionDelegate,
                                 DatePopoverViewControllerDelegate {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var selectOfficialButton: UIButton!
    @IBOutlet weak var selectLocationButton: UIButton!
    @IBOutlet weak var selectDateButton: UIButton!

    var event: Event?
    var selectedDate: Date?
    var selectedOfficial: Official?
    var selectedLocation: CLLocationCoordinate2D?
    var delegate:EventListDelegate?

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

    /// DatePopoverViewControllerDelegate
    func didSelectDate(date: Date) {
        self.set(date: date)
    }

    @IBAction func saveTapped(_ sender: Any) {
        if selectedOfficial == nil || selectedOfficial == nil || selectedLocation == nil {
            return
        }

        if (event != nil) {
            event!.name = eventNameTextField.text!
            event!.location = selectedLocation!
            event!.date = selectedDate!
            event!.official = selectedOfficial!

            event!.save { (event: Event?, error: Error?) in
                if (error != nil) {
                    print(error.debugDescription)
                } else {
                    print("Saved event.")
                }
            }

            delegate?.eventUpdatedDelegate()
        } else {
            let name = self.eventNameTextField.text!

            let newEvent = Event(name: name, owner: UsersDatabase.shared.getCurrentUserUID()!, location: self.selectedLocation!, date: self.selectedDate!, official: self.selectedOfficial!)

            newEvent.save { (event: Event?, error: Error?) in
                if (error != nil) {
                    print(error.debugDescription)
                } else {
                    print("Saved event.")
                }
            }

            if delegate != nil {
                delegate!.eventCreatedDelegate(event: newEvent)
            }
        }
        navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    /// UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SELECT_OFFICIAL_SEGUE) {
            let destination = segue.destination as! HomeViewController
            destination.reachType = .event
            destination.delegate = self
        } else if (segue.identifier == SELECT_LOCATION_SEGUE) {
            let destination = segue.destination as! MapViewController
            destination.reachType = .event
            destination.delegate = self
        } else if (segue.identifier == DATE_POPOVER_SEGUE) {
            let datePopoverViewController = segue.destination as! DatePopoverViewController
            datePopoverViewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            datePopoverViewController.popoverPresentationController?.delegate = self
                datePopoverViewController.delegate = self
            datePopoverViewController.popoverPresentationController?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
            datePopoverViewController.popoverPresentationController?.sourceView = view
            datePopoverViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
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
}
