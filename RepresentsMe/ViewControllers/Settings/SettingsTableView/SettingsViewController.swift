//
//  SettingsViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 3/11/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// The view controller that displays the settings the user can change
class SettingsViewController: UIViewController,
                              UITableViewDelegate {

    var tableViewDataSource:SettingsTableViewDataSource!
    var tableViewDelegate:SettingsTableViewDelegate!

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentUserLabel: UILabel!

    // MARK: - Lifecycle
    
    /// Set the data source and delegate
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the data source
        self.tableViewDataSource = SettingsTableViewDataSource(for: self)
        tableView.dataSource = self.tableViewDataSource
        
        // Set the delegate
        self.tableViewDelegate = SettingsTableViewDelegate(for: self)
        tableView.delegate = self.tableViewDelegate
        
        tableView.backgroundColor = .groupTableViewBackground
    }
    
    /// Sets up views when the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.frame = CGRect(x: tableView.frame.origin.x,
                                 y: tableView.frame.origin.y,
                                 width: tableView.frame.size.width,
                                 height: tableView.contentSize.height)
        currentUserLabel.text = "Logged in as " +
            (UsersDatabase.currentUserEmail ?? "N/A")
        tableView.reloadData()
    }
}
