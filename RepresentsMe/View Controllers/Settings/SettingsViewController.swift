//
//  SettingsViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 3/11/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

let SETTINGS_CELL_IDENTIFIER = "settingsCell"

enum SettingsOptions {
    case email
    case displayName
    case password
    case address
    case notifications
    case logout
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    // Data for Settings table view
    // [("Section Name", [(identifier,"Setting", "Image Name")]), ...]
    let data:[(String, [(SettingsOptions,String, String)])] =
        [("User", [(.email,"Email","envelope"),
                   (.displayName,"Username", "user"),
                   (.password,"Password", "key")]),
         ("", [(.address,"Address","home")]),
         ("", [(.notifications,"Notifications", "bell")]),
         ("", [(.logout,"Logout","sign-out-alt")])]
    let usersDB = UsersDatabase.getInstance()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.frame = CGRect(x: tableView.frame.origin.x,
                                 y: tableView.frame.origin.y,
                                 width: tableView.frame.size.width,
                                 height: tableView.contentSize.height)
        currentUserLabel.text = "Logged in as \(usersDB.getCurrentUserEmail () ?? "N/A")"
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentUserLabel: UILabel!

    // MARK: - Actions

    // MARK: - Methods
    func logout() {
        usersDB.logoutUser { (error) in
            if let _ = error {
                // TODO: Handle error
                print("Error while logging out: \(error.debugDescription)")
            } else {
                let storyBoard = UIStoryboard(name:"Main", bundle:nil)
                let entryViewController = storyBoard.instantiateViewController(withIdentifier: "entryViewController")
                guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
                appDel.window?.rootViewController = entryViewController
            }
        }
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SETTINGS_CELL_IDENTIFIER) as! SettingsCell

        let section = data[indexPath.section]
        let settingsForSection = section.1
        let settingForRow = settingsForSection[indexPath.row]

        cell.imageLabel.text = settingForRow.2
        cell.titleLabel.text = settingForRow.1
        cell.subtitleLabel.text = ""

        switch settingForRow.0 {
        case .email:
            cell.subtitleLabel.text = usersDB.getCurrentUserEmail()
            break
        case .displayName:
            cell.subtitleLabel.text = usersDB.getCurrentUserDisplayName()
            break
        case .password:
            break
        case .address:
            break
        case .notifications:
            break
        case .logout:
            break
        }
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
        let selectedRowSection = indexPath.section
        let selectedRow = indexPath.row
        tableView.deselectRow(at: indexPath, animated: false)
        switch (data[selectedRowSection].1)[selectedRow].0 {
        case .email:
            performSegue(withIdentifier: "emailSegue", sender: self)
            break
        case .displayName:
            performSegue(withIdentifier: "displayNameSegue", sender: self)
            break
        case .password:
            performSegue(withIdentifier: "passwordSegue", sender: self)
            break
        case .address:
            performSegue(withIdentifier: "addressSegue", sender: self)
            break
        case .notifications:
            break
        case .logout:
            // TODO: Logout
            logout()
            break
        }
    }
}
