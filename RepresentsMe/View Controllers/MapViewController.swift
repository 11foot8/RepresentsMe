//
//  MapViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 2/22/19.
//  Copyright © 2019 11foot8. All rights reserved.

import UIKit
import MapKit
import Foundation

let SANDBOX_OFFICIALS_SEGUE_IDENTIFIER = "sandboxOfficials"

class MapViewController: UIViewController, CLLocationManagerDelegate,
MKMapViewDelegate, UISearchBarDelegate, LocationInfoDelegate, UITextFieldDelegate {

    // MARK: - Properties
    let locationManager = CLLocationManager()
    
    let regionInMeters:CLLocationDistance = 10000            // Regions will be 10 km across

    var previousLocation:CLLocation?                         // Save previous location to limit
                                                             // geocode frequency
    var previousGeocodeTime:Date?

    let minimumDistanceForNewGeocode:CLLocationDistance = 50 // Only request new geocodes when
                                                             // pin is moved 50+ meters
    let minimumTimeForNewGecode:TimeInterval = 1             // Only request new geocode once per second
    
    let addressMessage = "Tap here to update address"

    var address:Address?

    var annotation:MKAnnotation?

    var workItem:DispatchWorkItem?

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchBarTextField: UITextField!
    @IBOutlet weak var locationInfoView: LocationInfo!

    // MARK: - Actions
    @IBAction func searchRequested(_ sender: Any) {
        // Hide keyboard when 'Search' is tapped
        searchBarTextField.resignFirstResponder()
        self.view.endEditing(true)
        let address:String = searchBarTextField.text!
        let geocoder = CLGeocoder()

        // Convert current mapView region to CLRegion to assist geocoder
        let region = convertRegion(mk: mapView.region)
        geocoder.geocodeAddressString(address, in: region, completionHandler: self.asyncGeocodeAddress)
    }

    func asyncGeocodeAddress(placemarks:[CLPlacemark]?, error:Error?) {
        if let _ = error {
            // TODO: Show alert informing user
            return
        }
        guard let placemark = placemarks?.first else {
            // TODO: show alert informing user search failed
            return
        }
        self.workItem = DispatchWorkItem{ self.geocodeAddressCompletionHandler(placemark: placemark)}
        DispatchQueue.main.async(execute: workItem!)
    }

    func geocodeAddressCompletionHandler(placemark:CLPlacemark) {
        let coords = placemark.location!.coordinate
        dropPin(coords: coords)
        self.centerView(on: coords, animated: false)
    }

    @IBAction func locateTouchUp(_ sender: Any) {
        centerViewOnUserLocation()
    }

    @objc func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .began { return }

        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        searchBarTextField.text = "Dropped Pin"

        dropPin(coords: touchMapCoordinate)

    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()

        // Set up Location Info View
        locationInfoView.delegate = self

        // Set up search bar
        searchBarView.layer.cornerRadius = 8    // round corners
        searchBarView.clipsToBounds = true
        searchBarView.layer.borderWidth = 1     // Draw border around entire view
        searchBarView.layer.borderColor = UIColor.lightGray.cgColor
        searchBarTextField.clearButtonMode = UITextField.ViewMode.always
        searchBarTextField.returnKeyType = .search
        searchBarTextField.delegate = self


        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress))
        mapView.addGestureRecognizer(longPressRecognizer)

        clearPin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

    // MARK: - Methods
    func clearPin() {
        if self.annotation != nil {
            mapView.removeAnnotation(self.annotation!)
        }
        locationInfoView.isHidden = true
    }

    func dropPin(coords:CLLocationCoordinate2D) {
        locationInfoView.isHidden = false
        if (self.annotation != nil) {
            mapView.removeAnnotation(self.annotation!)
            self.annotation = nil
        }
        self.annotation = DroppedPin(title: "Dropped Pin", locationName: "", discipline: "", coordinate: coords)
        mapView.addAnnotation(annotation!)
        locationInfoView.isHidden = false
        locationInfoView.updateWithCoordinates(coords: coords)
    }

    // MARK: - Location Utilities
    /// Check that location services are enabled, if so set up services, if not alert user that location services are
    /// not enabled.
    func checkLocationServices() {
        // Check if Location Services are enabled globally
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // TODO: show alert for letting user know they have to turn this on
        }

        previousLocation = getCenterLocation(for: mapView)
        previousGeocodeTime = Date()
    }

    /// Do setup for locationManager.
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    /// Check what location authorization the application has, and alert user if they need to take action to enable
    /// locaiton authorization.
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            startTrackingUserLocation()
            break
        case .denied:
            // TODO: show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // TODO: show an alert letting them know whats up
            break
        }
    }

    /// Show user location on map, begin updating user location, and center mapView on user location.
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        centerViewOnUserLocation()
        previousLocation = getCenterLocation(for: mapView)
        previousGeocodeTime = Date()
    }

    /// Center mapView on user location with default zoom level, animate transition.
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            centerView(on: location,animated: true)
        }
    }

    /// Center mapView on given locaiton.
    /// - Parameter location: Location on which to center mapView
    /// - Parameter animated: Whether or not to animate the transition
    func centerView(on location:CLLocationCoordinate2D, animated:Bool) {
        let region = MKCoordinateRegion.init(center:location,
                                             latitudinalMeters: regionInMeters,
                                             longitudinalMeters: regionInMeters)
        // Set zoom level
        mapView.setRegion(region, animated: animated)
        // Correct center
        mapView.setCenter(location, animated: animated)
    }

    /// Returns the current center location of mapView
    /// - Returns: Current center location of mapView
    func getCenterLocation(for mapView:MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    /// Convert MKCoordinateRegion to CLCircularRegion.
    func convertRegion(mk:MKCoordinateRegion) -> (CLCircularRegion) {
        // MKCoordinateRegion is a center and span
        //  Span is 2 values, latitudeDelta and longitudeDelta
        //  To convert to CLCircularRegion, a center and radius is needed

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
        // Hide keyboard when tapping out of SearchBar
        self.view.endEditing(true)
    }

    // MARK: - Searchbar
    // MARK: UITextFieldDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        clearPin()
        textField.resignFirstResponder()
        return false
    }

    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - LocationInfoDelegate
    func goButtonPressed(address: Address) {
        self.address = address
        // TODO: Check address validity - incl. addresses outside of US
        performSegue(withIdentifier: SANDBOX_OFFICIALS_SEGUE_IDENTIFIER, sender: self)
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            startTrackingUserLocation()
            break
        default:
            // TODO: Alert user that location is no longer authorized
            break

        }
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Handle error
    }

    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SANDBOX_OFFICIALS_SEGUE_IDENTIFIER {
            let destination = segue.destination as! HomeViewController
            destination.addr = self.address!
        }
    }
}
