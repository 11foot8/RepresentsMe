//
//  SettingsViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 3/11/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

let SETTINGS_CELL_IDENTIFIER = "settingsCell"
let SWITCH_SETTINGS_CELL_IDENTIFIER = "switchSettingsCell"

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum CellType {
        case Normal
        case Switch
    }

    @IBOutlet weak var tableView: UITableView!

    // Data for Settings table view
    // [("Section Name", CellType, [("Setting", "Image Name")]), ...]
    let data:[(String, CellType, [(String, String)])] = [("User", CellType.Normal,
                                                          [("Username", "user"), ("Password", "key")]),
                                                         ("", CellType.Normal,
                                                          [("Address", "home")]),
                                                         ("", CellType.Switch,
                                                          [("Notifications", "bell")])]

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
        let section = data[indexPath.section]
        let cellType = section.1

        let settingsForSection = section.2
        let settingForRow = settingsForSection[indexPath.row]

        var cell = SettingsCell()
        switch cellType {
            case .Normal:
                cell = tableView.dequeueReusableCell(withIdentifier: SETTINGS_CELL_IDENTIFIER) as! SettingsCell
            case .Switch:
                cell = tableView.dequeueReusableCell(withIdentifier: SWITCH_SETTINGS_CELL_IDENTIFIER) as! SwitchSettingsCell
        }

        cell.imageLabel.text = settingForRow.1
        cell.titleLabel.text = settingForRow.0
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].2.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 20))
        footerView.backgroundColor = .groupTableViewBackground
        return footerView
    }
}
