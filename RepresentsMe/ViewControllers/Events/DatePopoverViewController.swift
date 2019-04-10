//
//  DatePopoverViewController.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/8/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

protocol DatePopoverViewControllerDelegate {
    func didSelectDate(date: Date)
}

class DatePopoverViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    var delegate: DatePopoverViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveTapped(_ sender: Any) {
        delegate?.didSelectDate(date: datePicker.date)
        dismiss(animated: false, completion: nil)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
