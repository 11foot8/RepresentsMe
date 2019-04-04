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

var userAddr = Address(streetAddress: "110 Inner Campus Drive",
                       city: "Austin",
                       state: "TX",
                       zipcode: "78712") {
                didSet {
                    userAddrChanged = true
                }
}
var userAddrChanged = false

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var addr: Address = userAddr
    var officials: [Official] = []
    
    // MARK: - Outlets
    @IBOutlet weak var officialsTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        officialsTableView.delegate = self
        officialsTableView.dataSource = self

        if (LocationManager.shared.checkLocationServices()) {
            if let userLocation = LocationManager.shared.userLocation {
                GeocoderWrapper.reverseGeocodeCoordinates(userLocation.coordinate) { (address: Address) in
                    userAddr = address
                    self.addr = userAddr
                    self.getOfficials(for: userAddr)
                }
            }
        } else {
            getOfficials(for: addr)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // If the user changed the address in Settings or
        // we haven't been passed an address by the MapViewController,
        // get Officials with the user-specificed address
        if userAddrChanged {
            addr = userAddr
            userAddrChanged = false
            getOfficials(for: addr)
        }
    }

    // MARK: User Location
    func getOfficials(for address: Address) {
        OfficialScraper.getForAddress(address: address, apikey: civic_api_key) {
            (officialList: [Official]?, error: ParserError?) in
            if error == nil, let officialList = officialList {
                self.officials = officialList
                DispatchQueue.main.async {
                    self.navigationItem.title = "\(self.addr.city), \(self.addr.state)"
                    self.officialsTableView.reloadData()
                }
            }
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
            destination.official = officials[officialsIndex]
        }
    }
}
