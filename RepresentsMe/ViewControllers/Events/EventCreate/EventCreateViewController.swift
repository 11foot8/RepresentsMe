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
let START_DATE_POPOVER_SEGUE = "startDatePopoverSegue"
// EventCreateViewController -> DatePopoverViewController
let END_DATE_POPOVER_SEGUE = "endDatePopoverSegue"
// EventCreateViewController -> EventImportViewController
let IMPORT_EVENT_SEGUE = "importEventSegue"
// EventCreateViewController -> LocationMapPopoverViewController
let CREATE_MAP_POPOVER_SEGUE = "createMapPopoverSegue"

/// The view controller to handle creating and updating Events
class EventCreateViewController: UIViewController,
                                 OfficialSelectionDelegate,
                                 LocationSelectionDelegate,
                                 DatePopoverViewControllerDelegate,
                                 EventImportListener,
                                 UITextViewDelegate,
                                 UIScrollViewDelegate{

    // MARK: - Properties
    var event: Event?                               // The Event if editing
    var selectedStartDate: Date?                    // The selected start date
    var selectedEndDate: Date?                      // The selected end date
    var selectedOfficial: Official?                 // The selected Official
    var selectedLocation: CLLocationCoordinate2D?   // The selected location
    var selectedAddress: Address?                   // The selected address
    var delegate:EventListDelegate?                 // The delegate to update


    // MARK: - Outlets
    @IBOutlet weak var eventOfficialCardView: OfficialCardView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var selectOfficialButton: UIButton!
    @IBOutlet weak var selectLocationButton: UIButton!
    @IBOutlet weak var selectDateButton: UIButton!
    @IBOutlet weak var selectedStartDateLabel: UILabel!
    @IBOutlet weak var selectedEndDateLabel: UILabel!
    @IBOutlet weak var selectedLocationLabel: UILabel!
    @IBOutlet weak var importEventBarButton: UIBarButtonItem!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!

    // MARK: - Lifecycle
    /// Sets up the view for the Event if editing an Event
    override func viewDidLoad() {
        super.viewDidLoad()

        // If editing an Event, setup for that Event
        if let event = self.event {
            self.setupFor(event: event)
        }

        self.set(startDate: Date.init())
        self.set(endDate: Date.init())
        
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(handleTap))
        selectedLocationLabel.addGestureRecognizer(tapGestureRecognizer)

        let otherTapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
//        scrollView.addGestureRecognizer(otherTapGesture)

        importEventBarButton.image = UIImage.fontAwesomeIcon(
            name: .fileUpload,
            style: .solid,
            textColor: .blue,
            size: CGSize(width: 24, height: 24))

        descriptionTextView.layer.cornerRadius = 4.0
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.darkGray.cgColor
        descriptionTextView.clipsToBounds = true

        descriptionTextView.delegate = self
        scrollView.delegate = self

        showPlaceholderText()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)


    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        openMapView()
    }

    @objc func scrollViewTapped(_ gestureRecognizer: UIGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc func keyboardWillShow(notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomSpaceConstraint.constant = keyboardSize.height + 8
//            if descriptionTextView.isFirstResponder {
                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height + keyboardSize.height - scrollView.bounds.size.height)
                scrollView.setContentOffset(bottomOffset, animated: true)
//            }
        }
    }

    @objc func keyboardWillHide(notification:Notification) {
        bottomSpaceConstraint.constant = 8
    }

    // MARK: - Actions
    /// Creates or updates the Event when the save button is pressed.
    /// If successfully saves, segues back a view controller
    @IBAction func saveTapped(_ sender: Any) {
        // Ensure selected attributes are valid
        let description = ""            // TODO: fill in
        guard let official = selectedOfficial else {return}
        guard let location = selectedLocation else {return}
        guard let startDate = selectedStartDate else {return}
        guard let endDate = selectedEndDate else {return}
        let name = self.eventNameTextField.text!
        guard !name.isEmpty else {return}

        if event != nil {
            // Editing an Event, update it
            self.updateEvent(name: name,
                             official: official,
                             location: location,
                             startDate: startDate,
                             endDate: endDate)
        } else {
            // Not editing an Event, create a new Event
            self.createEvent(name: name,
                             description: description,
                             official: official,
                             location: location,
                             startDate: startDate,
                             endDate: endDate)
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
    @IBAction func mapButtonTouchUp(_ sender: Any) {
        openMapView()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        removePlaceholderText()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGray {
            showPlaceholderText()
        }
    }

    func openMapView() {
        if selectedLocation != nil {
            performSegue(withIdentifier: CREATE_MAP_POPOVER_SEGUE,
                         sender: self)
        }
    }

    func showPlaceholderText() {
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = UIColor.lightGray
    }

    func removePlaceholderText() {
        descriptionTextView.text = nil
        descriptionTextView.textColor = UIColor.black
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
        } else if segue.identifier == START_DATE_POPOVER_SEGUE {
            // Seguing to select a date
            let destination = segue.destination as! DatePopoverViewController
            destination.setup(in: self.view)
            destination.dateType = .start
            destination.delegate = self
        } else if segue.identifier == END_DATE_POPOVER_SEGUE {
            // Seguing to select a date
            let destination = segue.destination as! DatePopoverViewController
            destination.setup(in: self.view)
            destination.dateType = .end
            destination.delegate = self
        } else if segue.identifier == IMPORT_EVENT_SEGUE {
            let destination = segue.destination as! EventImportViewController
            destination.listener = self
        } else if segue.identifier == CREATE_MAP_POPOVER_SEGUE,
            let destination = segue.destination as? LocationMapViewPopoverViewController {
            destination.setPinInfo(location: selectedLocation!,
                                   title: eventNameTextField.text!,
                                   subtitle: selectedAddress!.addressLine1())
            destination.setup(in: self.view)
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
    /// - Parameter date:       the selected date
    /// - Parameter dateType:   the type of the date
    func didSelectDate(date: Date, dateType:DateType) {
        switch dateType {
        case .start:
            self.set(startDate: date)
            break
        case .end:
            self.set(endDate: date)
            break
        }
    }
    
    /// When an event is imported populate as many fields as possible with it
    func eventSelected(_ event: EKEvent) {
        self.eventNameTextField.text = event.title
        self.set(startDate: event.startDate)
        self.set(endDate: event.endDate)
        
        if let location = event.location {
            GeocoderWrapper.geocodeAddressString(location) {(placemark) in
                let address = Address(with: placemark)
                self.set(location: placemark.location!.coordinate,
                         address: address)
            }
        }
    }

    func setupLabels() {
        self.selectedStartDateLabel.layer.cornerRadius = 8.0
        self.selectedStartDateLabel.clipsToBounds = true
        self.selectedStartDateLabel.layer.borderColor = UIColor.lightGray.cgColor
        self.selectedStartDateLabel.layer.borderWidth = 1.0
        
        self.selectedEndDateLabel.layer.cornerRadius = 8.0
        self.selectedEndDateLabel.clipsToBounds = true
        self.selectedEndDateLabel.layer.borderColor = UIColor.lightGray.cgColor
        self.selectedEndDateLabel.layer.borderWidth = 1.0

        self.selectedLocationLabel.layer.cornerRadius = 8.0
        self.selectedLocationLabel.clipsToBounds = true
        self.selectedLocationLabel.layer.borderColor = UIColor.lightGray.cgColor
        self.selectedLocationLabel.layer.borderWidth = 1.0

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
        self.set(startDate: event.startDate)
        self.set(endDate: event.endDate)
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
        selectedAddress = address
        selectedLocationLabel.text = address.fullMultilineAddress()
    }
    
    /// Sets the start date for the Event
    ///
    /// - Parameter startDate:  the Date for the Event
    private func set(startDate:Date) {
        selectedStartDate = startDate
        
        // Format the date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, YYYY h:mm a"
        selectedStartDateLabel.text = formatter.string(from: startDate)
    }
    
    /// Sets the end date for the Event
    ///
    /// - Parameter endDate:    the Date for the Event
    private func set(endDate:Date) {
        selectedEndDate = endDate
        
        // Format the date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, YYYY h:mm a"
        selectedEndDateLabel.text = formatter.string(from: endDate)
    }
    
    /// Updates the Event.
    /// Segues back a view controller if successfully updates
    ///
    /// - Parameter name:       the new name
    /// - Parameter official:   the new Official
    /// - Parameter location:   the new location
    /// - Parameter startDate:  the new starting date
    /// - Parameter endDate:    the new ending date
    private func updateEvent(name:String,
                             official:Official,
                             location:CLLocationCoordinate2D,
                             startDate:Date,
                             endDate:Date) {
        if let event = event {
            event.name = name
            event.location = location
            event.startDate = startDate
            event.endDate = endDate
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
    /// - Parameter startDate:  the new starting date
    /// - Parameter endDate:    the new ending date
    private func createEvent(name:String,
                             description:String,
                             official:Official,
                             location:CLLocationCoordinate2D,
                             startDate:Date,
                             endDate:Date) {
        Event.create(name: name,
                     owner: UsersDatabase.currentUserUID!,
                     description: description,
                     location: location,
                     startDate: startDate,
                     endDate: endDate,
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
        self.resignFirstResponder()
    }
}
