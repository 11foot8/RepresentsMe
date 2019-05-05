//
//  MapViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 2/22/19.
//  Copyright © 2019 11foot8. All rights reserved.

import UIKit
import MapKit
import Foundation

// MapViewController -> OfficialsListViewController
let SANDBOX_OFFICIALS_SEGUE_IDENTIFIER = "sandboxOfficials"
// MapViewController -> SearchBarViewController
let SEARCH_BAR_SEGUE = "SearchBarSegue"
// MapViewController -> OfficialsListViewController
let LIST_MODAL_SEGUE_IDENTIFIER = "officialsModalSegue"

/// The protocol to implement to receive a location when the user selects a
/// location on the map.
protocol LocationSelectionDelegate {
    func didSelectLocation(location: CLLocationCoordinate2D, address: Address)
}

/// The view controller that displays a map for the user to interact with.
/// The map allows the user to drop pins, go to their current location, and go
/// to their home location. Depending on the mode, the map can send the
/// location to show Officials for the selected Address or to select the
/// location as the location for an Event.
class MapViewController: UIViewController {

    /// The modes avaliable for the map view controller
    enum ReachType {
        case map        // The sandbox mode
        case event      // The mode for selecting a location for an Event
        case settings   // The mode for selecting user's home location in settings
        case createAccount

        func title() -> String {
            switch self {
            case .map:
                return "Sandbox"
            case .event:
                return "Event"
            case .settings:
                return "Settings"
            case .createAccount:
                return "Create Account"
            }
        }
    }

    // MARK: - Properties
    // Make regions 10km across
    let regionInMeters:CLLocationDistance = 10000
    // Only request new geocodes when the pin has moved at least 50m
    let minimumDistanceForNewGeocode:CLLocationDistance = 50
    // Only request new geocode once per second
    let minimumTimeForNewGecode:TimeInterval = 1
    
    var previousLocation:CLLocation?
    var previousGeocodeTime:Date?
    var address:Address?
    var annotation:MKAnnotation?
    var reachType:ReachType = .map
    var delegate: LocationSelectionDelegate?

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var customSearchBar: CustomSearchBar!
    @IBOutlet weak var locationInfoView: LocationInfo!
    @IBOutlet weak var mapActionButtons: MapActionButtons!
    @IBOutlet weak var listButton: UIBarButtonItem!
    var backButton: UIBarButtonItem?

    // MARK: - Lifecycle
    /// Sets up the map view and delegates
    override func viewDidLoad() {
        super.viewDidLoad()

        // When view becomes active again (like returning from background), update
        // the MapActionButton LocationButton state
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // Setup the map view
        self.setupMapView()
        
        // Setup delegates
        locationInfoView.delegate = self
        customSearchBar.delegate = self
        mapActionButtons.delegate = self

        // Set search bar button appearance and disable
        customSearchBar.setMultifunctionButton(icon: .search, enabled: false)
    }
    
    /// Hide the navigation bar when the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.title = reachType.title()
        switch reachType {
        case .map:
                listButton.image = UIImage.fontAwesomeIcon(
                    name: .list,
                    style: .solid,
                    textColor: .blue,
                    size: CGSize(width: 24, height: 24))
                listButton.isEnabled = true
                break
        default:
            backButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
            listButton.image = nil
            listButton.isEnabled = false
            break
        }
    }

    /// Update the mapActionButton Location button
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapActionButtons.updateLocationButtonState()
    }

    /// To be called when app returns from background
    /// Updates mapActionButtons Location Button in case location services were modified
    @objc func appDidBecomeActive() {
        mapActionButtons.updateLocationButtonState()
    }
    
    /// Show the navigation bar when the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        delegate = nil
        reachType = .map
    }

    // MARK: - Actions
    /// Drops a pin on the selected location when a user long presses the map
    @objc func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            // Get GPS coordinates of press
            let touchMapCoordinate = mapView.convert(touchPoint,
                                                     toCoordinateFrom: mapView)

            // Create locationInfoItem for this location
            let locationInfoItem = LocationInfoItem(
                title:"Dropped Pin",
                coordinates: touchMapCoordinate)
            updateWith(locationInfoItem: locationInfoItem, replaceSearchedValue: true)
        }
    }

    @IBAction func listButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: LIST_MODAL_SEGUE_IDENTIFIER, sender: self)
    }

    // MARK: - Methods
    /// Clears the set pin
    func clearPin() {
        if let annotation = self.annotation {
            mapView.removeAnnotation(annotation)
            self.annotation = nil
        }
    }

    /// Drops a pin at the given coordinates
    ///
    /// - Parameter coords:                 the coordinates to drop the pin at
    /// - Parameter title:                  the title for the pin
    /// - Parameter replaceSearchedValue:   whether or not to replace the
    ///                                     search bar text
    func dropPin(coords:CLLocationCoordinate2D,
                 title:String,
                 replaceSearchedValue:Bool) {
        // Replace the search bar text
        if replaceSearchedValue {
            customSearchBar.setQuery(title)
        }
        
        // Remove an existing pins
        self.clearPin()

        // Drop the new pin
        self.annotation = DroppedPin(title: title,
                                     locationName: "",
                                     discipline: "",
                                     coordinate: coords)
        mapView.addAnnotation(annotation!)
    }

    /// Updates the View Controller for the given LocationInfoItem
    ///
    /// - Parameter locationInfoItem:       Item with new location information
    /// - Parameter replaceSearchedValue:   whether or not to replace the
    ///                                     search bar text
    func updateWith(locationInfoItem item:LocationInfoItem, replaceSearchedValue:Bool) {
        // Get coordinates for pin
        clearPin()
        if let coordinates = item.coordinates {
            centerView(on: coordinates,animated: true)
            dropPin(coords: coordinates,
                    title: item.title ?? "Unknown",
                    replaceSearchedValue: replaceSearchedValue)
        }
        // Get address for LocationInfoView
        locationInfoView.isHidden = false
        locationInfoView.startLoadingAnimation()
        item.getLocationInfo { (title, coordinates, address, error) in
            if let _ = error {
                // TODO: Handle error
                self.clearPin()
                return
            }
            guard let coordinates = coordinates else {
                self.clearPin()
                return
            }
            guard let address = address else {
                self.clearPin()
                return
            }
            // Drop pin if not already dropped
            if self.annotation == nil {
                self.centerView(on: coordinates,animated: true)
                self.dropPin(coords: coordinates,
                             title: item.title ?? title!,
                             replaceSearchedValue: replaceSearchedValue)
            }
            self.locationInfoView.updateWith(address:address, title:item.title ?? title!)
            self.locationInfoView.stopLoadingAnimation()
        }
    }

    /// Sets up the map view
    private func setupMapView() {
        // Default location to the center of the map
        previousLocation = getCenterLocation(for: mapView)
        previousGeocodeTime = Date()

        // Center the map on the user if they allowed location services
        if LocationManager.shared.checkLocationServices() {
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
        }

        // Setup long press gesture recognizer to drop pins
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(MapViewController.handleLongPress))
        mapView.addGestureRecognizer(longPressRecognizer)

        // Clear any previous pins
        clearPin()
        locationInfoView.isHidden = true
    }

    // MARK: - Location Utilities
    /// Center mapView on user location with default zoom level,
    /// animate transition.
    func centerViewOnUserLocation() {
        if let coordinate = LocationManager.shared.userCoordinate {
            centerView(on: coordinate, animated: true)
        }
    }

    /// Center mapView on given locaiton.
    ///
    /// - Parameter on:         Location on which to center mapView
    /// - Parameter animated:   Whether or not to animate the transition
    func centerView(on location:CLLocationCoordinate2D, animated:Bool) {
        let region = MKCoordinateRegion(center: location,
                                        latitudinalMeters: regionInMeters,
                                        longitudinalMeters: regionInMeters)
        // Set zoom level
        mapView.setRegion(region, animated: animated)
    }

    /// Returns the current center location of mapView
    ///
    /// - Parameter for:    the map view to get the center of
    ///
    /// - Returns: Current center location of mapView
    func getCenterLocation(for mapView:MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    /// Convert MKCoordinateRegion to CLCircularRegion.
    ///
    /// - Parameter mk:     the MKCoordinateRegion to convert
    ///
    /// - Returns: the converted CLCircularRegion
    func convertRegion(mk:MKCoordinateRegion) -> CLCircularRegion {
        // MKCoordinateRegion is a center and span
        // Span is 2 values, latitudeDelta and longitudeDelta
        // To convert to CLCircularRegion, a center and radius is needed

        let center = mk.center                      // Center of region
        let span = mk.span                          // Span of region

        // Northwest corner of region
        let nw = CLLocation(latitude:  center.latitude  + span.latitudeDelta  / 2,
                            longitude: center.longitude - span.longitudeDelta / 2)
        // Southeast corner of region
        let se = CLLocation(latitude:  center.latitude  - span.latitudeDelta  / 2,
                            longitude: center.longitude + span.longitudeDelta / 2)

        let radius = nw.distance(from: se) / 2      // Radius of region
        let region = CLCircularRegion(center: center,
                                      radius: radius,
                                      identifier: "region")
        
        // CLCircularRegion analog to MKCoordinateRegion
        return region
    }

    // MARK: - Keyboard
    /// Hide keyboard when tapping out of SearchBar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - Segue


    /// Prepare to segue to the Officials table view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SANDBOX_OFFICIALS_SEGUE_IDENTIFIER {
            let destination = segue.destination as! OfficialsListViewController
            destination.reachType = .map
        } else if segue.identifier == LIST_MODAL_SEGUE_IDENTIFIER {
            let destinationTabBarVC = segue.destination as? UITabBarController
            destinationTabBarVC?.selectedIndex = 0
            let destinationNavVC = destinationTabBarVC?.viewControllers?.first as? UINavigationController
            let destinationListVC = destinationNavVC?.viewControllers.first as! OfficialsListViewController

            destinationListVC.reachType = .home
        } else if segue.identifier == SEARCH_BAR_SEGUE {
            let destination = segue.destination as! SearchBarViewController
            destination.searchBarText = self.customSearchBar.searchBarText
            destination.region = mapView.region
            return
        }
    }

    @IBAction func unwindToMapView(segue: UIStoryboardSegue) {
        if segue.identifier == UNWIND_SEARCH_BAR_SEGUE {
            let source = segue.source as! SearchBarViewController
            self.customSearchBar.setQuery(source.searchBarText)
            switch source.unwindType! {
            case .backArrow:
                // Do not initiate any search, but update search bar
                break
            case .primaryButton,.suggestedResult:
                // Initiate search request
                if let searchRequest = source.searchRequest {
                    let locationInfoItem = LocationInfoItem(title: nil, searchRequest: searchRequest)
                    self.updateWith(locationInfoItem: locationInfoItem, replaceSearchedValue: false)
                }
                break
            }
        }
    }
}
// MARK: - CustomSearchBarDelegate
extension MapViewController: CustomSearchBarDelegate {
    /// Geocode the address given when search started and drop an pin on the
    /// location if one is found.
    ///
    /// - Parameter query:  the entered address
    func onSearchQuery(query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.region = mapView.region
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let response = response else {
                // TODO: Handle Error
                print("Error: \(error?.localizedDescription ?? "Unknown Error").")
                return
            }

            let coords = response.mapItems[0].placemark.location!.coordinate
            self.dropPin(coords: coords,
                         title: "Searched Address",
                         replaceSearchedValue: false)
            self.centerView(on: coords, animated: false)
        }
    }

    /// Clear any pins when the search bar is cleared
    func onSearchClear() {
        let _ = customSearchBar.resignFirstResponder()
        locationInfoView.isHidden = true
        clearPin()
    }

    func onSearchBegin() {
        performSegue(withIdentifier: SEARCH_BAR_SEGUE, sender: self)
    }

    func onSearchValueChanged() {
        // Do nothing
    }

    func multifunctionButtonPressed() {
        let _ = customSearchBar.resignFirstResponder()
        self.view.endEditing(true)
    }
}

// MARK: - LocationInfoDelegate
extension MapViewController: LocationInfoDelegate {
    /// Handles when the go button is pressed.
    /// If in the sandbox mode, show the Officials for the given Address.
    /// If selecting a location for an Event, send the Address back to the
    /// delegate.
    ///
    /// - Parameter address:    the selected Address
    func goButtonPressed(address: Address) {
        switch reachType {
        case .map:
            // Selected a location for the sandbox view, show the Officials for
            // that location
            AppState.sandboxAddress = address

            // TODO: Check address validity - incl. addresses outside of US
            performSegue(withIdentifier: SANDBOX_OFFICIALS_SEGUE_IDENTIFIER,
                         sender: self)
            break
        case .createAccount:
            delegate?.didSelectLocation(location: self.annotation!.coordinate,
                                        address: address)
            self.dismiss(animated: true, completion: nil)
            break
        default:
            // Selected a location for the Event, send location to the delegate
            // and dismiss
            // OR Selected a location for changing user's home address in settings,
            // send location to the delegate and dismiss
            delegate?.didSelectLocation(location: self.annotation!.coordinate,
                                        address: address)
            navigationController?.popViewController(animated: true)
            break
        }
    }
}

// MARK: - MapActionButtonsDelegate
extension MapViewController: MapActionButtonsDelegate {
    /// Centers the map on the user's current location
    func onLocateTouchUp() {
        if let coordinate = LocationManager.shared.userCoordinate {
            mapView.showsUserLocation = true
            let locationInfoItem = LocationInfoItem(
                title:"Current Location",
                coordinates: coordinate)
            updateWith(locationInfoItem: locationInfoItem, replaceSearchedValue: true)
        }
    }

    /// Move view to user's saved address and drop a pin
    func onHomeTouchUp() {
        guard let address = AppState.homeAddress else { return }
        let locationInfoItem = LocationInfoItem(
            title: "Home",
            address: address)
        self.updateWith(locationInfoItem: locationInfoItem, replaceSearchedValue: true)
    }
}
