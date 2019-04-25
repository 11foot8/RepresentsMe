//
//  SearchBarTableViewCell.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/23/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit

class SearchBarTableViewCell: UITableViewCell {
    // MARK: - Properties
    private var _searchResult:MKLocalSearchCompletion?
    var searchResult:MKLocalSearchCompletion? {
        get {
            return nil
        }
        set(searchResult) {
            self._searchResult = searchResult
        }
    }

    // MARK: - Outlets
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Actions

    // MARK: - Methods
    
}
