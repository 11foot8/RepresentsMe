//
//  HomeViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 2/23/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import CoreLocation

let OFFICIAL_CELL_IDENTIFIER = "officialCell"
let DETAILS_SEGUE_IDENTIFIER = "detailsSegueIdentifier"

var userAddr = Address(streetNumber: "201",
                       streetName: "Gregson St",
                       city: "Durham",
                       state: "NC",
                       zipcode: "27701") {
                didSet {
                    userAddrChanged = true
                }
}
var userAddrChanged = false

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    // MARK: Properties
    var addr: Address? = nil
    var officials: [Official] = []
    
    // MARK: Outlets
    @IBOutlet weak var officialsTableView: UITableView!

    let locationManager = CLLocationManager()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        officialsTableView.delegate = self
        officialsTableView.dataSource = self

        checkLocationServices()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // If the user changed the address in Settings or
        // we haven't been passed an address by the MapViewController,
        // get Officials with the user-specificed address
        if addr == nil || userAddrChanged {
            addr = userAddr
            userAddrChanged = false
            getOfficials(for: addr!)
        }
    }

    // MARK: User Location
    func getOfficials(for address: Address) {
        OfficialScraper.getForAddress(address: address, apikey: civic_api_key) {
            (officialList: [Official]?, error: ParserError?) in
            if error == nil, let officialList = officialList {
                self.officials = officialList
                DispatchQueue.main.async {
                    self.navigationItem.title = "\(self.addr!.city), \(self.addr!.state)"
                    self.officialsTableView.reloadData()
                }
            }
        }
    }

    /// Check that location services are enabled, if so set up services,
    /// if not alert user that location services are not enabled.
    func checkLocationServices() {
        // Check if Location Services are enabled globally
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

    /// Check what location authorization the application has, and alert user if
    /// they need to take action to enable location authorization.
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            getReverseGeocode()
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

    func getReverseGeocode() {
        let location = locationManager.location    // Current coordinates to geocode
        let geoCoder = CLGeocoder()              // Geocoder instance to use

        if location == nil {
            return
        }

        // Request will come back with 'placemarks' and 'error' as parameters
        geoCoder.reverseGeocodeLocation(location!) { (placemarks, error) in
            // If an error occured, alert user and return immediately
            if let _ = error {
                // TODO: Show alert informing the user
                return
            }

            // placemark is a list of results, if no results returned, alert user and return immediately
            guard let placemark = placemarks?.first else {
                // TODO: Show alert informing the user
                return
            }

            // Get address from the placemark, save it, and reload Officials
            userAddr = Address(with: placemark)
            self.addr = userAddr
            self.getOfficials(for: userAddr)
        }
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return officials.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OFFICIAL_CELL_IDENTIFIER,
                                                 for: indexPath) as! OfficialCell
        cell.official = officials[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DETAILS_SEGUE_IDENTIFIER,
            let destination = segue.destination as? DetailsViewController,
            let officialsIndex = officialsTableView.indexPathForSelectedRow?.row {
            destination.passedOfficial = officials[officialsIndex]
        }
    }
}
