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
    var officials: [Official] = []

    var reachType: HomeViewControllerReachType = .home
    var delegate: OfficialSelectionDelegate?
    let locationManager = CLLocationManager()
    
    // MARK: - Outlets
    @IBOutlet weak var officialsTableView: UITableView!
    var address: Address? {
        didSet {
            needToPull = true
        }
    }
    var needToPull:Bool = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        officialsTableView.delegate = self
        officialsTableView.dataSource = self

        switch reachType {
        case .home, .event:
            // TODO: Get current user address
            UsersDatabase.shared.getCurrentUserAddress { (address, error) in
                if let _ = error {
                    // TODO: Handle error
                    print(error.debugDescription)
                } else {
                    self.address = address
                    self.getOfficials(for: self.address!)
                }
            }
        case .map:
            self.getOfficials(for: self.address!)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.address == nil || self.needToPull {
            switch reachType {
            case .home, .event:
                // TODO: Get current user address
                UsersDatabase.shared.getCurrentUserAddress { (address, error) in
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
                switch self.reachType {
                case .home, .event:
                    AppState.homeOfficials = officialList
                    break
                case .map:
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
        switch self.reachType {
        case .home, .event:
            return AppState.homeOfficials.count
        case .map:
            return AppState.sandboxOfficials.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: OFFICIAL_CELL_IDENTIFIER,
            for: indexPath) as! OfficialCell
        
        switch reachType {
        case .home, .event:
            cell.official = AppState.homeOfficials[indexPath.row]
            break
        case .map:
            cell.official = AppState.sandboxOfficials[indexPath.row]
        }
        
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch reachType {
        case .home, .map:
            performSegue(withIdentifier: DETAILS_VIEW_SEGUE, sender: self)
            break
        case .event:
            delegate?.didSelectOfficial(official: AppState.homeOfficials[indexPath.row])
            navigationController?.popViewController(animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DETAILS_VIEW_SEGUE,
            let destination = segue.destination as? DetailsViewController,
            let indexPath = officialsTableView.indexPathForSelectedRow {
            officialsTableView.deselectRow(at: indexPath, animated: false)
            switch self.reachType {
            case .home, .event:
                destination.official = AppState.homeOfficials[indexPath.row]
            case .map:
                destination.official = AppState.sandboxOfficials[indexPath.row]
            }
        }
    }
}
