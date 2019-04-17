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

        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true

        locateButton.layer.borderWidth = 1.0
        locateButton.layer.borderColor = UIColor.lightGray.cgColor
        updateLocationButtonState()

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

    func updateLocationButtonState() {
        locateButton.isEnabled = LocationManager.shared.locationServicesEnabledAndAuthorized()
        if locateButton.isEnabled {
            locateButton.alpha = 1.0
        } else {
            locateButton.alpha = 0.5
        }
    }

    func updateHomeButtonState() {
        if let _ = UsersDatabase.currentUser {
            homeButton.isEnabled = true
            homeButton.alpha = 1.0
        } else {
            homeButton.isEnabled = false
            homeButton.alpha = 0.5
        }
    }

    func didChangeLocationAuthorization() {
        updateLocationButtonState()
    }
}
