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

enum TableViewModes {
    case HomeMode // Home mode, uses current user's address
    case SandboxMode // Sandbox mode, uses address from mapview
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    // MARK: - Properties
    var address: Address?
    var officials: [Official] = []
    let locationManager = CLLocationManager()
    let usersDB = UsersDatabase.getInstance()
    var mode:TableViewModes = TableViewModes.HomeMode

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        officialsTableView.delegate = self
        officialsTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch mode {
        case .HomeMode:
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
        case .SandboxMode:
            // TODO: Use current address
            self.getOfficials(for: self.address!)
            break
        }
    }

    // MARK: - Outlets
    @IBOutlet weak var officialsTableView: UITableView!

    // MARK: - User Location
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
