//
//  EventImportDelegate.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/29/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import EventKit

protocol EventImportListener {
    func eventSelected(_ event:EKEvent)
}

/// The delegate to handle when an event is selected to be imported
class EventImportDelegate: NSObject, UITableViewDelegate {
    
    var parent:EventImportViewController!
    
    /// Setup the delegate for the table view
    ///
    /// - Parameter with:   the parent view controller
    init(with parent:EventImportViewController) {
        self.parent = parent
        super.init()
        self.parent.tableView.delegate = self
    }
    
    /// When an event is selected, pass that event to the listener and dismiss
    /// the event import table view controller
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let event = self.parent.dataSource.events[indexPath.row]
        self.parent.listener.eventSelected(event)
        self.parent.navigationController?.popViewController(animated: true)
    }
}
