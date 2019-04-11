//
//  DatePopoverViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/8/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// The protocol to implement to receive the date when a date is selected
protocol DatePopoverViewControllerDelegate {
    func didSelectDate(date: Date)
}

/// View controller to show a popover to select a date
class DatePopoverViewController: PopoverViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: DatePopoverViewControllerDelegate?

    /// Send the selected date to the delegate and close
    @IBAction func saveTapped(_ sender: Any) {
        delegate?.didSelectDate(date: datePicker.date)
        dismiss(animated: false, completion: nil)
    }

    /// Close without sending the date to the delegate
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
