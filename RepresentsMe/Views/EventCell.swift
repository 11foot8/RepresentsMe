//
//  EventCell.swift
//  RepresentsMe
//
//  Created by Varun Adiga on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class EventCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var loadingIndicator: NVActivityIndicatorView!
    
    var event:Event? {
        didSet {
            nameLabel.text = event?.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd h:mm a"
            dateLabel.text = dateFormatter.string(from: event!.startDate)
            detailsLabel.text = ""
            
            eventImageView.image = nil
            loadingIndicator.isHidden = false
            loadingIndicator.color = event?.official?.party.color ?? .black
            loadingIndicator.startAnimating()
            event?.official?.getPhoto(completion: { (photoOfficial, image) in
                // Ensure that photo is matched to correct cell
                if (photoOfficial == self.event?.official) {
                    DispatchQueue.main.async {
                        self.eventImageView.image = image
                        self.loadingIndicator.isHidden = true
                        self.loadingIndicator.stopAnimating()
                    }
                }
            })
            
            eventImageView.layer.cornerRadius = 8.0
            eventImageView.clipsToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // TODO: Define behavior on selection
    }
}
