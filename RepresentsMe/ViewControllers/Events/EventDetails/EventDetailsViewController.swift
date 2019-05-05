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
import EventKit
import NVActivityIndicatorView
import Firebase

// EventDetailsViewController -> EventCreateViewController
let EDIT_EVENT_SEGUE = "editEventSegue"
// EventDetailsViewController -> OfficialDetailsViewController
let EVENT_OFFICIAL_SEGUE = "eventOfficialSegue"
// EventDetailsViewController -> EventsListViewController
let OWNER_EVENTS_SEGUE = "ownerEventsSegue"
// EventDetailsViewController -> EventsListViewController
let USER_EVENTS_SEGUE = "userEventsSegue"

let EVENT_MAP_VIEW_POPOVER_SEGUE = "eventMapViewPopoverSegue"

// RSVP colors
let GOING_GREEN = UIColor(displayP3Red: 51.0 / 255.0,
                          green: 204.0 / 255.0,
                          blue: 51.0 / 255.0,
                          alpha: 1.0)
let MAYBE_ORANGE = UIColor.orange
let NOT_GOING_RED = UIColor.red

/// The view controller to display the details for an Event and allow the
/// owner of the Event to edit and delete the Event.
class EventDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - Properties
    var toolbarOut: CGPoint = CGPoint()
    var toolbarIn: CGPoint = CGPoint()

    var event:Event? {                            // The Event to display
        didSet {
            if let userID = event?.owner {
                UsersDatabase.getDisplayName(for: userID) { (displayName, error) in
                    self.eventOwnerDisplayName = displayName
                }
            }
        }
    }
    var eventOwnerDisplayName:String?
    var delegate:EventListDelegate?               // The delegate to update
    var currentUserEventAttendee:EventAttendee?   // The EventAttendee instance
                                                  // for the current user
    let eventStore = EKEventStore()

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var eventOwnerImageView: UIImageView!
    @IBOutlet weak var loadingIndicator: NVActivityIndicatorView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var officialNameButton: UIButton!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editButtonLabel: UILabel!
    @IBOutlet weak var deleteEventButton: UIButton!
    @IBOutlet weak var deleteEventButtonLabel: UILabel!

    @IBOutlet weak var goingButton: UIButton!
    @IBOutlet weak var goingButtonLabel: UILabel!
    @IBOutlet weak var maybeButton: UIButton!
    @IBOutlet weak var maybeButtonLabel: UILabel!
    @IBOutlet weak var notGoingButton: UIButton!
    @IBOutlet weak var notGoingButtonLabel: UILabel!
    @IBOutlet weak var toolbarView: UIView!

    @IBOutlet weak var goingNumberLabel: UILabel!
    @IBOutlet weak var maybeNumberLabel: UILabel!

    @IBOutlet weak var attendeeCollectionView: UICollectionView!

    var attendeeDataGoing:Bool = true

    var goingAttendees:[EventAttendee] = []
    var maybeAttendees:[EventAttendee] = []

    // MARK: - Lifecycle
    /// Sets up the view for the Event to display
    override func viewWillAppear(_ animated: Bool) {
        if event != nil {
            // Set the labels
            setLabels()

            // Set the photos
            setPhotos()

            // Center the map on the location for the event
            setupMapView()

            // Set up toolbar
            setupToolbar()

            // Set whether or not the user can edit the event
            setEditable()

            // Set user's RSVP status
            setRSVPButtons()

            // Set the event attendees
            setEventAttendees()
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: - Actions
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

    @objc func didTapToolbar(tapGestureRecognizer: UITapGestureRecognizer) {
        if toolbarView.frame.origin == toolbarOut {
            UIView.animate(withDuration: 0.5) {
                self.toolbarView.frame.origin = self.toolbarIn
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.toolbarView.frame.origin = self.toolbarOut
            }
        }
    }

    @IBAction func officialNameButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: EVENT_OFFICIAL_SEGUE, sender: self)
    }

    /// Sets the labels for the Event
    private func setLabels() {
        if let event = self.event {
            eventNameLabel.text = event.name
            officialNameButton.setTitle(event.official?.name, for: .normal)
            eventDateLabel.text = event.formattedDate
    
            // Set the location
            self.eventLocationLabel.text = event.address.description
        }
    }

    @IBAction func setRSVPGoing(_ sender: Any) {
        setRSVPStatus(status: .going)
    }

    @IBAction func setRSVPMaybe(_ sender: Any) {
        setRSVPStatus(status: .maybe)
    }

    @IBAction func setRSVPNotGoing(_ sender: Any) {
        setRSVPStatus(status: .notGoing)
    }

    @IBAction func exportEvent(_ sender: Any) {
        let name = self.event?.name
        let startDate = self.event?.startDate
        let endDate = self.event?.endDate

        // If the authorization status for calendar access isn't authorized, request
        // access again and then export the event. Otherwise, just export the event
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                (granted, error) in
                self.saveEvent(eventStore:self.eventStore,
                               title:name!,
                               startDate: startDate! as NSDate,
                               endDate: endDate! as NSDate)
            })
        } else {
            saveEvent(eventStore:eventStore,
                      title:name!,
                      startDate: startDate! as NSDate,
                      endDate: endDate! as NSDate)
        }
    }

    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if let _ = event?.location {
            performSegue(withIdentifier: EVENT_MAP_VIEW_POPOVER_SEGUE, sender: self)
        }
    }
    
    /// Sets the photo for the Event
    private func setPhotos() {
        if let event = self.event {
            if let photo = event.official?.photo {
                portraitImageView.image = photo
            }
            portraitImageView.layer.cornerRadius = 5.0

            loadingIndicator.isHidden = false
            loadingIndicator.color = .black
            loadingIndicator.startAnimating()
            ownerLabel.isHidden = true
            UsersDatabase.getUserProfilePicture(uid: event.owner) { (uid, image, error) in
                if (error != nil) {
                    self.eventOwnerImageView.isHidden = true
                } else {
                    if let image = image {
                        self.eventOwnerImageView.image = image
                        self.ownerLabel.isUserInteractionEnabled = true
                        self.loadingIndicator.isHidden = true
                        self.loadingIndicator.isUserInteractionEnabled = false
                        self.ownerLabel.isHidden = false
                        self.ownerLabel.isUserInteractionEnabled = false

                        self.eventOwnerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapEventOwnerImage)))
                    }
                }
                self.loadingIndicator.stopAnimating()
            }
            eventOwnerImageView.layer.cornerRadius = 5.0
        }
    }

    @objc private func didTapEventOwnerImage() {
        performSegue(withIdentifier: OWNER_EVENTS_SEGUE, sender: self)
    }

    /// Prepare to segue to edit the Event
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == EDIT_EVENT_SEGUE {
            let destination = segue.destination as! EventCreateViewController
            destination.event = event
            destination.delegate = delegate
        } else if segue.identifier == EVENT_OFFICIAL_SEGUE {
            let destination = segue.destination as! OfficialDetailsViewController
            destination.official = event?.official
        } else if segue.identifier == OWNER_EVENTS_SEGUE {
            let destination = segue.destination as! EventsListViewController
            destination.displayName = eventOwnerDisplayName
            destination.reachType = .user
            AppState.userId = event!.owner
        } else if segue.identifier == USER_EVENTS_SEGUE {
            let destination = segue.destination as! EventsListViewController
            destination.reachType = .user

            if let rowNum = attendeeCollectionView.indexPathsForSelectedItems?.first?.row {
                if attendeeDataGoing {
                    AppState.userId = goingAttendees[rowNum].userID
                } else {
                    AppState.userId = maybeAttendees[rowNum].userID
                }

                destination.displayName = nil
                UsersDatabase.getDisplayName(for: AppState.userId!) { (displayName, error) in
                    if let displayName = displayName {
                        destination.navigationItem.title = "\(displayName)'s Events"
                    }
                }
            }
        } else if segue.identifier == EVENT_MAP_VIEW_POPOVER_SEGUE,
            let destination = segue.destination as? LocationMapViewPopoverViewController {
            destination.setPinInfo(location: event!.location, title: event!.name, subtitle: event!.address.addressLine1())
            destination.setup(in: self.view)
        }
    }

    private func setupToolbar() {
        toolbarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToolbar(tapGestureRecognizer:))))

        var bottomArea: CGFloat = 0.0

        if let tabBarHeight = tabBarController?.tabBar.frame.height {
            bottomArea += tabBarHeight
        }

        toolbarIn = CGPoint(x: 0, y: UIScreen.main.bounds.maxY - bottomArea - 16)
        toolbarOut = CGPoint(x: 0, y: UIScreen.main.bounds.maxY - bottomArea - toolbarView.frame.size.height)

        toolbarView.center = toolbarIn;
        view.layoutIfNeeded()
    }

    /// Centers the map on the location for the Event
    private func setupMapView() {
        if let event = self.event {
            let span = MKCoordinateSpan(latitudeDelta: 0.1,
                                        longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: event.location, span: span)
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(DroppedPin(title: event.name,
                                                  locationName: "",
                                                  discipline: "",
                                                  coordinate: event.location))
        }
    }

    func setRSVPStatus(status: RSVPType) {
        // If user already has RSVPed, set status or remove self
        if let attendee = currentUserEventAttendee {
            // If pressed button for current status, set layout to "no response"
            if (attendee.status == status) {
                event?.removeAttendee(userID: UsersDatabase.currentUserUID!, completion: { (attendee: EventAttendee, error: Error?) in
                    if (error != nil) {
                        // TODO: Handle error
                    }

                    self.setNoResponseLayout()

                    AppState.removeRSVP(event: self.event)
                })

                reloadAttendeeViews(status: .notGoing)

                currentUserEventAttendee = nil

                return
            } else {
                attendee.setStatus(to: status)
                reloadAttendeeViews(status: status)
            }
        } else {
            // If user has not yet RSVPed, add self
            if let uid = UsersDatabase.currentUserUID {
                event?.addAttendee(userID: uid, status: status,
                                   completion: { (attendee: EventAttendee, error: Error?) in
                                    if (error != nil) {
                                        // TODO: Handle error
                                    }

                                    self.currentUserEventAttendee = attendee
                                    self.reloadAttendeeViews(status: status)

                                    AppState.addRSVP(event: self.event)
                })
            } else {
                self.alert(title: "Error",
                           message: "You must be logged in to RSVP for an event.")
                return
            }
        }

        switch status {
        case .going:
            self.setRSVPGoingLayout()
            break
        case .maybe:
            self.setRSVPMaybeLayout()
            break
        case .notGoing:
            self.setRSVPNotGoingLayout()
            break
        }
    }
    
    func saveEvent(eventStore:EKEventStore, title:String, startDate:NSDate, endDate:NSDate) {
        let event = EKEvent(eventStore:eventStore)
        event.title = title
        if let officialName = self.event?.official?.name {
            event.notes = "Event with \(officialName). Exported from RepresentsMe."
        }
        event.location = self.event?.address.description
        event.startDate = startDate as Date?
        event.endDate = endDate as Date?
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Alert the user to let them know if the export succeeded or failed
        // If succeeded, give the user the option to open up the calendar app.g
        do {
            try eventStore.save(event,span:.thisEvent)
            if AppState.openCalendarOnEventExport {
                let interval = startDate.timeIntervalSinceReferenceDate
                UIApplication.shared.open(NSURL(string: "calshow:\(interval)")! as URL)

            } else {
                exportEventAlert(date: startDate as Date)
            }
        } catch {
            self.alert(title: "Error", message: "Unable to export event to calendar")
        }
    }
    
    /// Presents an alert specific to when an event is exported. Takes user to the
    /// calendar app if they so desire
    ///
    /// - Parameter date:      the date at which the exported event is taking place.
    private func exportEventAlert(date: Date) {
        let interval = date.timeIntervalSinceReferenceDate
        let alert = UIAlertController(
            title: "Success",
            message: "The event has been exported to your calendar. Would you like to open up the calendar app?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            UIApplication.shared.open(NSURL(string: "calshow:\(interval)")! as URL)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        self.present(alert, animated: true)
    }

    /// Sets up the edit views based on whether or not the user is allowed to
    /// edit the Event
    private func setEditable() {
        if let event = self.event {
            if (UsersDatabase.currentUserUID == event.owner) {
                // User owns the event, let them edit it
                editButton.isEnabled = true
                deleteEventButton.isEnabled = true
            } else {
                // User does not own the event, do not let them edit it
                editButton.isEnabled = false
                dimButtonLabel(button: editButton, label: editButtonLabel)
                deleteEventButton.isEnabled = false
                dimButtonLabel(button: deleteEventButton, label: deleteEventButtonLabel)
            }
        }
    }

    private func setRSVPButtons() {
        dimButtonLabel(button: goingButton, label: goingButtonLabel)
        goingButton.isUserInteractionEnabled = false
        dimButtonLabel(button: maybeButton, label: maybeButtonLabel)
        maybeButton.isUserInteractionEnabled = false
        dimButtonLabel(button: notGoingButton, label: notGoingButtonLabel)
        notGoingButton.isUserInteractionEnabled = false

        event?.loadAttendees(completion: { (event: Event?, error: Error?) in
            if error != nil {
                // TODO: Handle error
            }

            if let event = event {
                DispatchQueue.main.async {
                    self.attendeeCollectionView.reloadData()
                }

                self.goingAttendees = event.attendees.filter({ (attendee) -> Bool in
                    return attendee.status == .going
                }).sorted(by: { (attendee1, attendee2) -> Bool in
                    attendee1.userID < attendee2.userID
                })

                self.goingNumberLabel.text = String(self.goingAttendees.count)

                self.maybeAttendees = event.attendees.filter({ (attendee) -> Bool in
                    return attendee.status == .maybe
                }).sorted(by: { (attendee1, attendee2) -> Bool in
                    attendee1.userID < attendee2.userID
                })

                self.maybeNumberLabel.text = String(self.maybeAttendees.count)

                for attendee in event.attendees {
                    if attendee.userID == UsersDatabase.currentUserUID! {
                        self.currentUserEventAttendee = attendee
                        switch attendee.status {
                        case .going:
                            self.setRSVPGoingLayout()
                            break
                        case .maybe:
                            self.setRSVPMaybeLayout()
                            break
                        case .notGoing:
                            self.setRSVPNotGoingLayout()
                            break
                        }
                        self.enableRSVPButtons()
                        return
                    }
                }
                self.setNoResponseLayout()
                self.enableRSVPButtons()
            }
        })
    }

    private func reloadAttendeeViews(status: RSVPType) {
        self.maybeAttendees.removeAll { (attendee) -> Bool in
            return attendee.userID == self.currentUserEventAttendee?.userID
        }

        self.goingAttendees.removeAll { (attendee) -> Bool in
            return attendee.userID == self.currentUserEventAttendee?.userID
        }

        if (status == .going) {
            self.goingAttendees.append(self.currentUserEventAttendee!)
        } else if (status == .maybe) {
            self.maybeAttendees.append(self.currentUserEventAttendee!)
        }

        self.goingNumberLabel.text = String(self.goingAttendees.count)
        self.maybeNumberLabel.text = String(self.maybeAttendees.count)

        DispatchQueue.main.async {
            self.attendeeCollectionView.reloadData()
        }
    }

    private func setEventAttendees() {
        attendeeCollectionView.delegate = self
        attendeeCollectionView.dataSource = self
        attendeeCollectionView.isHidden = true

        goingNumberLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goingNumberLabelTapped)))

        maybeNumberLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(maybeNumberLabelTapped)))
    }

    @objc func goingNumberLabelTapped() {
        attendeeCollectionView.isHidden = !attendeeCollectionView.isHidden && attendeeDataGoing
        attendeeDataGoing = true
        attendeeCollectionView.reloadData()
    }

    @objc func maybeNumberLabelTapped() {
        attendeeCollectionView.isHidden = !attendeeCollectionView.isHidden && !attendeeDataGoing
        attendeeDataGoing = false
        attendeeCollectionView.reloadData()
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !attendeeCollectionView.isHidden {
            if attendeeDataGoing {
                return goingAttendees.count
            } else {
                return maybeAttendees.count
            }
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let attendeeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "attendeeCell", for: indexPath) as! AttendeeCell

        if attendeeDataGoing {
            attendeeCell.attendee = goingAttendees[indexPath.row]
        } else {
            attendeeCell.attendee = maybeAttendees[indexPath.row]
        }

        attendeeCell.profileImageView.layer.cornerRadius = 5.0

        return attendeeCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: USER_EVENTS_SEGUE, sender: self)
    }

    func setNoResponseLayout() {
        goingButton.setTitleColor(GOING_GREEN, for: .normal)
        goingButtonLabel.textColor = GOING_GREEN
        goingButtonLabel.font = UIFont.systemFont(ofSize: 10.0)

        maybeButton.setTitleColor(MAYBE_ORANGE, for: .normal)
        maybeButtonLabel.textColor = MAYBE_ORANGE
        maybeButtonLabel.font = UIFont.systemFont(ofSize: 10.0)

        notGoingButton.setTitleColor(NOT_GOING_RED, for: .normal)
        notGoingButtonLabel.textColor = NOT_GOING_RED
        notGoingButtonLabel.font = UIFont.systemFont(ofSize: 10.0)
    }

    func setRSVPGoingLayout() {
        goingButton.setTitleColor(GOING_GREEN, for: .normal)
        goingButtonLabel.textColor = GOING_GREEN
        goingButtonLabel.font = UIFont.boldSystemFont(ofSize: 10.0)

        dimButtonLabel(button: maybeButton, label: maybeButtonLabel)
        dimButtonLabel(button: notGoingButton, label: notGoingButtonLabel)
    }

    func setRSVPMaybeLayout() {
        maybeButton.setTitleColor(MAYBE_ORANGE, for: .normal)
        maybeButtonLabel.textColor = MAYBE_ORANGE
        maybeButtonLabel.font = UIFont.boldSystemFont(ofSize: 10.0)

        dimButtonLabel(button: goingButton, label: goingButtonLabel)
        dimButtonLabel(button: notGoingButton, label: notGoingButtonLabel)
    }

    func setRSVPNotGoingLayout() {
        notGoingButton.setTitleColor(NOT_GOING_RED, for: .normal)
        notGoingButtonLabel.textColor = NOT_GOING_RED
        notGoingButtonLabel.font = UIFont.boldSystemFont(ofSize: 10.0)

        dimButtonLabel(button: goingButton, label: goingButtonLabel)
        dimButtonLabel(button: maybeButton, label: maybeButtonLabel)
    }

    func dimButtonLabel(button: UIButton, label: UILabel) {
        button.setTitleColor(.lightGray, for: .normal)
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 10.0)
    }

    func enableRSVPButtons() {
        self.goingButton.isUserInteractionEnabled = true
        self.maybeButton.isUserInteractionEnabled = true
        self.notGoingButton.isUserInteractionEnabled = true
    }
}
