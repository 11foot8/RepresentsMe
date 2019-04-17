//
//  MapActionButtons.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

protocol MapActionButtonsDelegate {
    func onLocateTouchUp()
    func onHomeTouchUp()
}

class MapActionButtons: UIView, LocationAuthorizationListener {


    // MARK: - Properties
    var delegate:MapActionButtonsDelegate? = nil

    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!

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
        let nib = UINib(nibName: "MapActionButtons", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        contentView.frame = bounds
        addSubview(contentView)

        // Round corners of buttons
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true

        locateButton.layer.borderWidth = 1.0
        locateButton.layer.borderColor = UIColor.lightGray.cgColor
        // Check set location button state appropriately
        updateLocationButtonState()

        // Add listener to listen for location authorization changes while in use
        LocationManager.addLocationAuthorizationListener(self)

        homeButton.layer.borderWidth = 1.0
        homeButton.layer.borderColor = UIColor.lightGray.cgColor
        updateHomeButtonState()
    }

    @IBAction func locateTouchUp(_ sender: Any) {
        guard delegate != nil else { return }
        delegate?.onLocateTouchUp()
    }

    @IBAction func homeTouchUp(_ sender: Any) {
        guard delegate != nil else { return }
        delegate?.onHomeTouchUp()
    }

    /// Set location button state appropriately depending on
    /// whether locations services are enabled and authorized
    func updateLocationButtonState() {
        locateButton.isEnabled = LocationManager.shared.locationServicesEnabledAndAuthorized()
        if locateButton.isEnabled {
            locateButton.alpha = 1.0
        } else {
            locateButton.alpha = 0.5
        }
    }

    /// Set home button state appropriately depending on
    /// whether a user is logged in or not
    func updateHomeButtonState() {
        if let _ = UsersDatabase.currentUser {
            homeButton.isEnabled = true
            homeButton.alpha = 1.0
        } else {
            homeButton.isEnabled = false
            homeButton.alpha = 0.5
        }
    }

    // MARK: - LocationAuthorizationListener
    /// If location authorization changes while running, this will be called
    func didChangeLocationAuthorization() {
        updateLocationButtonState()
    }
}
