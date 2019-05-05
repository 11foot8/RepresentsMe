//
//  DatePopoverViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/8/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// The type of date being picked
enum DateType {
    case start
    case end
}

/// The protocol to implement to receive the date when a date is selected
protocol DatePopoverViewControllerDelegate {
    func didSelectDate(date:Date, dateType:DateType)
}

/// View controller to show a popover to select a date
class DatePopoverViewController: PopoverViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: DatePopoverViewControllerDelegate?
    var dateType:DateType!

    /// Send the selected date to the delegate and close
    @IBAction func saveTapped(_ sender: Any) {
        delegate?.didSelectDate(date: datePicker.date, dateType: dateType)
        dismiss(animated: false, completion: nil)
    }

    /// Close without sending the date to the delegate
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
