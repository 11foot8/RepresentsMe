//
//  OfficialCell.swift
//  RepresentsMe
//
//  Created by Benny Singer on 2/23/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

let PORTRAIT_SIZE = CGSize(width: 100, height: 100)

class OfficialCell: UITableViewCell {

    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var officeLabel: UILabel!
    @IBOutlet weak var partyLabel: UILabel!
    @IBOutlet weak var loadingIndicator: NVActivityIndicatorView!
    
    var official: Official? {
        didSet {
            nameLabel.text = official?.name
            officeLabel.text = official?.office
            partyLabel.text = official?.party.name

            portraitImageView.image = nil
            loadingIndicator.isHidden = false
            loadingIndicator.color = official?.party.color ?? .black
            loadingIndicator.startAnimating()
            official?.getPhoto(completion: { (photoOfficial, image) in
                // Ensure that photo is matched to correct cell
                if (photoOfficial == self.official) {
                    DispatchQueue.main.async {
                        self.portraitImageView.image = image
                        self.loadingIndicator.isHidden = true
                        self.loadingIndicator.stopAnimating()
                    }
                }
            })

            portraitImageView.layer.cornerRadius = 8.0
            portraitImageView.clipsToBounds = true
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
