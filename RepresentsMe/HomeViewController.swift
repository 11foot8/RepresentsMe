//
//  HomeViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 2/23/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

let OFFICIAL_CELL_IDENTIFIER = "officialCell"
let TEMP_ADDR = "201 Gregson St. Durham, NC 27701"

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var officialsTableView: UITableView!

    var officials: [Official] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        officialsTableView.delegate = self
        officialsTableView.dataSource = self

        OfficialScraper.getForAddress(address: TEMP_ADDR, apikey: civic_api_key) { (officialList: [Official]?, error: ParserError?) in
            if error == nil {
                if let officialList = officialList {
                    self.officials = officialList
                    self.officialsTableView.reloadData()
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
}
