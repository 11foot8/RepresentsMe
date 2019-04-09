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

enum TableViewModes {
    case HomeMode // Home mode, uses current user's address
    case SandboxMode // Sandbox mode, uses address from mapview
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    // MARK: - Properties
    var address: Address? {
        didSet {
            needToPull = true
        }
    }
    let locationManager = CLLocationManager()
    let usersDB = UsersDatabase.getInstance()
    var mode:TableViewModes = TableViewModes.HomeMode
    var needToPull:Bool = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        officialsTableView.delegate = self
        officialsTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.address == nil || self.needToPull {
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
    }

    // MARK: - Outlets
    @IBOutlet weak var officialsTableView: UITableView!

    // MARK: - User Location
    func getOfficials(for address: Address) {
        OfficialScraper.getForAddress(address: address, apikey: civic_api_key) {
            (officialList: [Official]?, error: ParserError?) in
            if error == nil, let officialList = officialList {
                switch self.mode {
                case .HomeMode:
                    AppState.homeOfficials = officialList
                    break
                case .SandboxMode:
                    AppState.sandboxOfficials = officialList
                    break
                }
                
                DispatchQueue.main.async {
                    self.needToPull = false
                    self.navigationItem.title = "\(self.address!.city), \(self.address!.state)"
                    self.officialsTableView.reloadData()
                }
            }
        }
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.mode {
        case .HomeMode:
            return AppState.homeOfficials.count
        case .SandboxMode:
            return AppState.sandboxOfficials.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: OFFICIAL_CELL_IDENTIFIER,
            for: indexPath) as! OfficialCell
        
        switch self.mode {
        case .HomeMode:
            cell.official = AppState.homeOfficials[indexPath.row]
            break
        case .SandboxMode:
            cell.official = AppState.sandboxOfficials[indexPath.row]
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DETAILS_SEGUE_IDENTIFIER,
            let destination = segue.destination as? DetailsViewController,
            let officialsIndex = officialsTableView.indexPathForSelectedRow?.row {
            
            switch self.mode {
            case .HomeMode:
                destination.passedOfficial = AppState.homeOfficials[officialsIndex]
            case .SandboxMode:
                destination.passedOfficial = AppState.sandboxOfficials[officialsIndex]
            }
        }
    }
}
