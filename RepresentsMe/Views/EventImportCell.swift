//
//  EventImportCell.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/29/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import EventKit

/// The table view cell to display a calendar event that can be imported
class EventImportCell: UITableViewCell {
    
    var event:EKEvent! {
        didSet {
            // Set the views when an event is given
            nameLabel.text = event.title
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            dateLabel.text = formatter.string(from: event.startDate) + "-" +
                formatter.string(from: event.endDate)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}
