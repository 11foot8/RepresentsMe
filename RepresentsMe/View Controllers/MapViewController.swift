//
//  MapViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 2/22/19.
//  Copyright © 2019 11foot8. All rights reserved.

import UIKit
import MapKit

let SANDBOX_OFFICIALS_SEGUE_IDENTIFIER = "sandboxOfficials"

class MapViewController: UIViewController, CLLocationManagerDelegate,
                            MKMapViewDelegate, UISearchBarDelegate {
    
    // MARK: Properties
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

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!

    // MARK: Actions
    @IBAction func addressButtonTouchUp(_ sender: Any) {
        let center = getCenterLocation(for: mapView)
        let time = Date()
        guard let previousLocation = self.previousLocation else { return }
        guard let previousGeocodeTime = self.previousGeocodeTime else { return }

        guard center.distance(from: previousLocation) > minimumDistanceForNewGeocode
            || time.timeIntervalSince(previousGeocodeTime) > minimumTimeForNewGecode else { return }

        getReverseGeocode()
    }

    @IBAction func goButtonTouchUp(_ sender: Any) {
        // TODO: Check address validity - incl. addresses outside of US
        performSegue(withIdentifier: SANDBOX_OFFICIALS_SEGUE_IDENTIFIER, sender: self)
    }

    @IBAction func locateTouchUp(_ sender: Any) {
        centerViewOnUserLocation()
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        addressButton.titleLabel?.lineBreakMode = .byWordWrapping
        resetButtons()
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

    // MARK: Methods
    /// Reset address button and go button to default states.
    func resetButtons() {
        addressButton.setTitle(addressMessage, for: .normal)
        goButton.isUserInteractionEnabled = false
        goButton.backgroundColor = .gray
    }

    /// Enable go button.
    func enableGoButton() {
        self.goButton.isUserInteractionEnabled = true
        self.goButton.backgroundColor = .black
    }

    /// Check that location services are enabled, if so set up services, if not alert user that location services are
    /// not enabled.
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // TODO: show alert for letting user know they have to turn this on
        }
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

    /// Reverse geocodes the current center location of mapView.
    /// Attempts to retrieve an address from the current center coordinates of mapView
    /// Upon successful reverse geocode, sets title of address button to resulting address and enables go button.
    func getReverseGeocode() {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let _ = error {
                // TODO: Show alert informing the user
                return
            }
            
            guard let placemark = placemarks?.first else {
                // TODO: Show alert informing the user
                return
            }
            
            self.address = Address(with: placemark)
            
            DispatchQueue.main.async {
                self.addressButton.setTitle("\(self.address!)", for: .normal)
                self.enableGoButton()
            }
        }
    }

    /// Convert MKCoordinateRegion to CLCircularRegion.
    func convertRegion(mk:MKCoordinateRegion) -> (CLCircularRegion) {
        let center = mk.center
        let span = mk.span
        let nw = CLLocation(latitude:  center.latitude  + span.latitudeDelta  / 2,
                            longitude: center.longitude - span.longitudeDelta / 2)
        let se = CLLocation(latitude:  center.latitude  - span.latitudeDelta  / 2,
                            longitude: center.longitude + span.longitudeDelta / 2)
        let radius = nw.distance(from: se)
        let region = CLCircularRegion(center: center, radius: radius, identifier: "region")
        return region
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Handle error
    }

    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        guard let previousLocation = self.previousLocation else { return }
        
        if (previousLocation.distance(from: center) > minimumDistanceForNewGeocode) {
            resetButtons()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SANDBOX_OFFICIALS_SEGUE_IDENTIFIER {
            let destination = segue.destination as! HomeViewController
            destination.addr = self.address!
        }
    }

    // MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Hide keyboard when 'Search' is tapped
        self.view.endEditing(true)
        let address:String = searchBar.text!
        let geocoder = CLGeocoder()

        // Convert current mapView region to CLRegion to assist geocoder
        let region = convertRegion(mk: mapView.region)
        geocoder.geocodeAddressString(address, in: region) { (placemarks, error) in
            if let _ = error {
                // TODO: Show alert informing user
                return
            }
            guard let placemark = placemarks?.first else {
                // TODO: show alert informing user search failed
                return
            }
            DispatchQueue.main.async {
                self.centerView(on: (placemark.location?.coordinate)!, animated: false)
            }
        }
    }
}
