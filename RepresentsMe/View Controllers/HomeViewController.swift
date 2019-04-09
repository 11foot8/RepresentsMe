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
let DETAILS_VIEW_SEGUE = "detailsViewSegue"
let UNWIND_TO_CREATE_EVENT_SEGUE = "unwindToCreateEventViewController"

protocol OfficialSelectionDelegate {
    func didSelectOfficial(official: Official)
}

var userAddr = Address(streetAddress: "110 Inner Campus Drive",
                       city: "Austin",
                       state: "TX",
                       zipcode: "78712") {
                didSet {
                    userAddrChanged = true
                }
}
var userAddrChanged = false

enum HomeViewControllerReachType {
    case home
    case map
    case event
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var addr: Address = userAddr
    var officials: [Official] = []
    var reachType: HomeViewControllerReachType = .home
    var delegate: OfficialSelectionDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var officialsTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        officialsTableView.delegate = self
        officialsTableView.dataSource = self

        if (reachType == .home || reachType == .event) {
            self.navigationItem.title = "Home"
            if (LocationManager.shared.checkLocationServices()) {
                if let userCoordinate = LocationManager.shared.userCoordinate {
                    GeocoderWrapper.reverseGeocodeCoordinates(userCoordinate) { (address: Address) in
                        userAddr = address
                        self.addr = userAddr
                        self.getOfficials(for: userAddr)
                    }
                }
            } else {
                getOfficials(for: addr)
            }
        } else {
            self.navigationItem.title = addr.addressCityState()
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate = nil
        reachType = .home
    }

    // MARK: User Location
    func getOfficials(for address: Address) {
        OfficialScraper.getForAddress(address: address, apikey: civic_api_key) {
            (officialList: [Official]?, error: ParserError?) in
            if error == nil, let officialList = officialList {
                self.officials = officialList
                DispatchQueue.main.async {
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
        if (reachType == .home || reachType == .map) {
            performSegue(withIdentifier: DETAILS_VIEW_SEGUE, sender: self)
        } else if reachType == .event {
            delegate?.didSelectOfficial(official: officials[indexPath.row])
            performSegue(withIdentifier: UNWIND_TO_CREATE_EVENT_SEGUE, sender: self)
        }
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DETAILS_VIEW_SEGUE,
            let destination = segue.destination as? DetailsViewController,
            let indexPath = officialsTableView.indexPathForSelectedRow
        {
            officialsTableView.deselectRow(at: indexPath, animated: false)
            destination.official = officials[indexPath.row]
        }
    }
}
