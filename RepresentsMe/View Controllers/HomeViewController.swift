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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    
    // MARK: - Properties
    var address: Address?
    var officials: [Official] = []

    var reachType: HomeViewControllerReachType = .home
    var delegate: OfficialSelectionDelegate?
    let locationManager = CLLocationManager()
    let usersDB = UsersDatabase.getInstance()
    
    // MARK: - Outlets
    @IBOutlet weak var officialsTableView: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        officialsTableView.delegate = self
        officialsTableView.dataSource = self

        switch reachType {
        case .home, .event:
            // TODO: Get current user address
            usersDB.getCurrentUserAddress { (address, error) in
                if let _ = error {
                    // TODO: Handle error
                    print(error.debugDescription)
                } else {
                    self.address = address
                    self.getOfficials(for: self.address!)
                }
            }
            break
        case .map:
            // TODO: Use current address
            self.getOfficials(for: self.address!)
            break
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if userAddrChanged {
            address = userAddr
            userAddrChanged = false
            getOfficials(for: address!)
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
                    self.navigationItem.title = "\(self.address!.city), \(self.address!.state)"
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
        switch reachType {
        case .home, .map:
            performSegue(withIdentifier: DETAILS_VIEW_SEGUE, sender: self)
            break
        case .event:
            delegate?.didSelectOfficial(official: officials[indexPath.row])
            navigationController?.popViewController(animated: true)
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
