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

enum HomeViewControllerReachType {
    case home
    case map
    case event
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AppStateListener {
    // MARK: - Properties
    var reachType: HomeViewControllerReachType = .home
    var delegate: OfficialSelectionDelegate?
    
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
            AppState.addListener(listener: self)
            break
        case .map:
            break
        }

        loadOfficials()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadOfficials()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate = nil
    }

    func appStateReceivedHomeOfficials(officials: [Official]) {
        self.address = AppState.homeAddress
        DispatchQueue.main.async {
            self.officialsTableView.reloadData()
        }
    }

    func loadOfficials() {
        switch reachType {
        case .home, .event:
            self.navigationItem.title = "Home"
            break
        case .map:
            // TODO: Use current address
            self.getOfficials(for: self.address!)
            break
        }
    }

    // MARK: User Location
    func getOfficials(for address: Address) {
        self.address = address
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
                    switch self.reachType {
                    case .home, .event:
                        self.navigationItem.title = "Home"
                        break
                    case .map:
                        self.navigationItem.title = "\(self.address!.city), \(self.address!.state)"
                    }

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
            break
        }

        switch reachType {
        case .home, .map:
            cell.accessoryType = .disclosureIndicator
            break
        case .event:
            cell.accessoryType = .none
            break
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
