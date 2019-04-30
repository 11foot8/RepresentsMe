//
//  EventImportViewController.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/29/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import EventKit

/// View controller to display a table view of calendar events that the user
/// can choose to import
class EventImportViewController: UIViewController {
    
    var dataSource:EventImportDataSource!
    var delegate:EventImportDelegate!
    var listener:EventImportListener!
    
    @IBOutlet weak var tableView: UITableView!
    
    /// Setup the data source and delegate
    override func viewDidLoad() {
        self.dataSource = EventImportDataSource(for: self.tableView)
        self.delegate = EventImportDelegate(with: self)
    }
}
