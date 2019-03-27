//
//  SettingsViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 3/11/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

let SETTINGS_CELL_IDENTIFIER = "settingsCell"

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    // Data for Settings table view
    // [("Section Name", [("Setting", "Image Name")]), ...]

    // Full Settings data for Beta release
    // let data:[(String, [(String, String)])] = [("User", [("Username", "user"), ("Password", "key")]),
    //                                           ("", [("Address","home")]),
    //                                           ("", [("Notifications", "bell")])]
    let data:[(String, [(String, String)])] = [("", [("Address","home")])]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.frame = CGRect(x: tableView.frame.origin.x,
                                 y: tableView.frame.origin.y,
                                 width: tableView.frame.size.width,
                                 height: tableView.contentSize.height)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SETTINGS_CELL_IDENTIFIER) as! SettingsCell

        let section = data[indexPath.section]
        let settingsForSection = section.1
        let settingForRow = settingsForSection[indexPath.row]

        cell.imageLabel.text = settingForRow.1
        cell.titleLabel.text = settingForRow.0
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].1.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 20))
        footerView.backgroundColor = .groupTableViewBackground
        return footerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Alter when Settings table expands
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "addressSegue", sender: self)
    }
}
