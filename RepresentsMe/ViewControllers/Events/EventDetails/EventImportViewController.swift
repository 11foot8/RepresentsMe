//
//  EventImportViewController.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/29/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import EventKit

class EventImportViewController: UIViewController {
    
    var dataSource:EventImportDataSource!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        self.dataSource = EventImportDataSource(for: self.tableView)
    }
}
