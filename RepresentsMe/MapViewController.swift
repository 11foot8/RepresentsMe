//
//  MapViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 2/22/19.
//  Copyright © 2019 11foot8. All rights reserved.

// code borrowed from tutorial at https://www.youtube.com/watch?v=2wxE8byc2FQ
// https://www.dropbox.com/sh/keburc19mdiitj8/AADBqv7k0FnlWUQzIuni58Iba?dl=0
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    // Regions will be 10 km across
    let regionInMeters:CLLocationDistance = 10000
    // Save previous location to limit geocode frequency
    var previousLocation:CLLocation?
    var previousGeocodeTime:Date?
    // only request new geocodes when pin is moved 50+ meters
    let minimumDistanceForNewGeocode:CLLocationDistance = 50
    // only request new geocodes once every second
    let minimumTimeForNewGecode:TimeInterval = 1
    
    let addressMessage = "Tap here to update address"

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    @IBAction func addressButtonTouchUp(_ sender: Any) {
        let center = getCenterLocation(for: mapView)
        let time = Date()
        guard let previousLocation = self.previousLocation else { return }
        guard let previousGeocodeTime = self.previousGeocodeTime else { return }
        
        guard center.distance(from: previousLocation) > minimumDistanceForNewGeocode || time.timeIntervalSince(previousGeocodeTime) > minimumTimeForNewGecode else { return }
        
        getReverseGeocode()
        
        
    }
    @IBAction func goButtonTouchUp(_ sender: Any) {
        // TODO: Check address validity
        // TODO: Send address to representative table view
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        // Do any additional setup after loading the view.
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // set up our location manager
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // show alert for letting user know they have to turn this on
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
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
        case .authorizedAlways:
            // Never should have this authorization
            break
        }
    }
    
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
        previousGeocodeTime = Date()
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center:location, latitudinalMeters:regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
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
                print("error:: ",error!)
                return
            }
            
            guard let placemark = placemarks?.first else {
                // TODO: Show alert informing the user
                print("No placemark")
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
//            let country = placemark.country ?? ""
            let zipcode = placemark.postalCode ?? ""
            
            DispatchQueue.main.async {
                self.addressButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                self.addressButton.setTitle("\(streetNumber) \(streetName)\n\(city), \(state) \(zipcode)", for: .normal)
            }
            
            
        }
    }
}

extension MapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        guard let location = locations.last else { return }
        //        let region = MKCoordinateRegion.init(center:location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        //        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        guard let previousLocation = self.previousLocation else { return }
        
        if (previousLocation.distance(from: center) > minimumDistanceForNewGeocode) {
            addressButton.setTitle(addressMessage, for: .normal)
        }
        
        
    }
}
