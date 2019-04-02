//
//  LocationInfo.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/1/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit
import NVActivityIndicatorView

protocol LocationInfoDelegate {
    func goButtonPressed(address:Address)
}


class LocationInfo: UIView {

    // MARK: - Properties
    var delegate:LocationInfoDelegate?
    var address:Address?
    var workItem:DispatchWorkItem? = nil

    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var address1Label: UILabel!
    @IBOutlet weak var address2Label: UILabel!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!

    // MARK: - Actions
    @IBAction func goButtonTouchUp(_ sender: Any) {
        guard delegate != nil else { return }
        delegate?.goButtonPressed(address: address!)
    }


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
        let nib = UINib(nibName: "LocationInfo", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        self.layer.cornerRadius = 18
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        contentView.frame = bounds
        addSubview(contentView)

        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true

        goButton.layer.cornerRadius = 10
        goButton.clipsToBounds = true

        activityIndicator.isHidden = true
    }


    /// Reverse geocodes the given location.
    /// Upon successful reverse geocode, sets locationInfoView correctly
    func updateWithCoordinates(coords:CLLocationCoordinate2D) {
        startLoadingAnimation()

        let geocoder = CLGeocoder()

        let location = CLLocation(latitude: coords.latitude, longitude: coords.longitude)

        geocoder.reverseGeocodeLocation(location, completionHandler: asyncGeocode)

    }

    func asyncGeocode(placemarks:[CLPlacemark]?, error:Error?) {
        // If an error occured, alert user and return immediately
        if let _ = error {
            // TODO: Show alert informing the user
            return
        }

        // placemark is a list of results, if no results returned, alert user and return immediately
        guard let placemark = placemarks?.first else {
            // TODO: Show alert informing the user
            return
        }

        // Get address from the placemark
        let address = Address(with: placemark)

        if workItem != nil {
            workItem?.cancel()
        }

        self.workItem = DispatchWorkItem{ self.geocodeCompletionHandler(address:address)}
        DispatchQueue.main.async(execute: self.workItem!)
    }

    func geocodeCompletionHandler(address:Address) {
        self.address = address
        // In UI thread, set title of address button and enable go button
        self.titleLabel.text = "Dropped Pin"
        let streetNo = self.address!.streetNumber
        let streetName = self.address!.streetName
        let city = self.address!.city
        let state = self.address!.state
        let zip = self.address!.zipcode
        self.address1Label.text = "\(streetNo) \(streetName)"
        self.address2Label.text = "\(city), \(state) \(zip)"
        self.goButton.isEnabled = true
        stopLoadingAnimation()
    }

    func startLoadingAnimation() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        goButton.isEnabled = false
        goButton.isHidden = true
        titleLabel.isHidden = true
        address1Label.isHidden = true
        address2Label.isHidden = true
    }

    func stopLoadingAnimation() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        goButton.isEnabled = true
        goButton.isHidden = false
        titleLabel.isHidden = false
        address1Label.isHidden = false
        address2Label.isHidden = false

    }
}
