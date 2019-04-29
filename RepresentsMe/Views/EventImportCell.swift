//
//  EventImportCell.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 4/29/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import EventKit

class EventImportCell: UITableViewCell {
    
    var event:EKEvent! {
        didSet {
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
