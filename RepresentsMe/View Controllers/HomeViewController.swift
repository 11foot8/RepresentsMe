//
//  HomeViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 2/23/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

let OFFICIAL_CELL_IDENTIFIER = "officialCell"

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var officialsTableView: UITableView!

    var addr = Address(streetNumber: "201",
                       streetName: "Gregson St",
                       city: "Durham",
                       state: "NC",
                       zipcode: "27701")
    var officials: [Official] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        officialsTableView.delegate = self
        officialsTableView.dataSource = self

        navigationItem.title = addr.streetRepr()

        OfficialScraper.getForAddress(address: addr, apikey: civic_api_key) {
            (officialList: [Official]?, error: ParserError?) in
            if error == nil {
                if let officialList = officialList {
                    self.officials = officialList
                    DispatchQueue.main.async {
                        self.officialsTableView.reloadData()
                    }
                }
            }
            // TODO: Handle ParserErrors
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return officials.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OFFICIAL_CELL_IDENTIFIER,
                                                 for: indexPath) as! OfficialCell
        cell.official = officials[indexPath.row]
        return cell
    }
    
    let detailsSegueIdentifier = "detailsSegueIdentifier"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailsSegueIdentifier,
            let destination = segue.destination as? DetailsViewController,
            let officialsIndex = officialsTableView.indexPathForSelectedRow?.row {
            destination.passedName = officials[officialsIndex].name
            destination.passedSeat = officials[officialsIndex].office
            destination.passedParty = officials[officialsIndex].party
            destination.passedEmails = officials[officialsIndex].emails
            destination.passedPhoneNums = officials[officialsIndex].phones
            if let officialsPic = officials[officialsIndex].photo {
                destination.passedPicture = officialsPic
            }
        }
    }
}
