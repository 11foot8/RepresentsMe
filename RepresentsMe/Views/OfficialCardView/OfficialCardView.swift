//
//  OfficialCardView.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/11/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// A view that represents a card showing an officials information
class OfficialCardView: UIView {
    // MARK: - Properties

    var official:Official?  // Official this card represents

    // MARK: - Outlets

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var officialImageView: UIImageView!
    @IBOutlet weak var officialNameLabel: UILabel!
    @IBOutlet weak var officialSeatLabel: UILabel!
    @IBOutlet weak var officialPartyLabel: UILabel!

    // MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        let nib = UINib(nibName: "OfficialCardView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        contentView.frame = bounds
        addSubview(contentView)

        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true

        setupImageView()
    }

    // MARK: - Actions

    // MARK: -

    /// Sets the card info for the given official
    ///
    /// - Parameter official:   Official for which to set this card's data
    func set(official:Official?) {
        if let official = official {
            self.official = official
            officialImageView.image = official.photo
            officialNameLabel.text = official.name
            officialSeatLabel.text = official.office
            officialPartyLabel.text = official.party.name
            officialPartyLabel.textColor = official.party.color
        }
    }

    /// Sets up the image view
    private func setupImageView() {
        officialImageView.layer.cornerRadius = 5.0
        officialImageView.clipsToBounds = true
        officialImageView.image = DEFAULT_NOT_LOADED
    }
}
