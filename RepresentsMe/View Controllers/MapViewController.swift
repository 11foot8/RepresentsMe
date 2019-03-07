//
//  MapViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 2/22/19.
//  Copyright © 2019 11foot8. All rights reserved.

import UIKit
import MapKit

let SANDBOX_OFFICIALS_SEGUE_IDENTIFIER = "sandboxOfficials"

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
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

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var goButton: UIButton!

    var address:Address?

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        addressButton.titleLabel?.lineBreakMode = .byWordWrapping
        resetButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: Actions
    @IBAction func addressButtonTouchUp(_ sender: Any) {
        let center = getCenterLocation(for: mapView)
        let time = Date()
        guard let previousLocation = self.previousLocation else { return }
        guard let previousGeocodeTime = self.previousGeocodeTime else { return }
        
        guard center.distance(from: previousLocation) > minimumDistanceForNewGeocode || time.timeIntervalSince(previousGeocodeTime) > minimumTimeForNewGecode else { return }
        
        getReverseGeocode()
    }
    
    @IBAction func goButtonTouchUp(_ sender: Any) {
        // TODO: Check address validity - incl. addresses outside of US
        performSegue(withIdentifier: SANDBOX_OFFICIALS_SEGUE_IDENTIFIER, sender: self)
    }
    
    @IBAction func locateTouchUp(_ sender: Any) {
        centerViewOnUserLocation()
    }
    
    // MARK: Methods
    func resetButtons() {
        addressButton.setTitle(addressMessage, for: .normal)
        goButton.isUserInteractionEnabled = false
        goButton.backgroundColor = .gray
    }

    func enableGoButton() {
        self.goButton.isUserInteractionEnabled = true
        self.goButton.backgroundColor = .black
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // TODO: show alert for letting user know they have to turn this on
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
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
    
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        centerViewOnUserLocation()
        previousLocation = getCenterLocation(for: mapView)
        previousGeocodeTime = Date()
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center:location, latitudinalMeters:regionInMeters, longitudinalMeters: regionInMeters)
            // Set zoom level
            mapView.setRegion(region, animated: true)
            // Correct center
            mapView.setCenter(location, animated: true)
        }
    }
    
    func getCenterLocation(for mapView:MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
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
}
