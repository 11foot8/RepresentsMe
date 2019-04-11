//
//  StatePopoverViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/3/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

/// The protocol to implement to receive the state when one is selected
protocol StatePopoverViewControllerDelegate {
    func didSelectState(state:String)
}

/// The view controller to allow the user to select a state
class StatePopoverViewController: PopoverViewController,
                                  UIPickerViewDelegate,
                                  UIPickerViewDataSource {

    // MARK: - Properties
    static let states = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT",
                         "DE", "DC", "FL", "GA", "HI", "ID", "IL",
                         "IN", "IA", "KS", "KT", "LA", "ME", "MD",
                         "MA", "MI", "MN", "MS", "MO", "MT", "NE",
                         "NV", "NH", "NJ", "NM", "NY", "NC", "ND",
                         "OH", "OK", "OR", "PA", "RI", "SC", "SD",
                         "TN", "TX", "UT", "VT", "VA", "WA", "WV",
                         "WI", "WY"]
    
    var delegate:StatePopoverViewControllerDelegate?
    var selectedValue:String?

    // MARK: - Outlets
    @IBOutlet weak var pickerView: UIPickerView!

    // MARK: - Lifecycle
    
    /// Set the initially selected value
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        if let selectedValue = self.selectedValue {
            if let index = StatePopoverViewController.states.firstIndex(
                of: selectedValue) {
                // Select the given value
                pickerView.selectRow(index, inComponent: 0, animated: false)
            } else {
                // Invalid selected value given, default to the first value
                pickerView.selectRow(0, inComponent: 0, animated: false)
            }
        }
    }

    // MARK: - Actions
    
    /// Send the selected state and dismiss the view controller
    @IBAction func doneTouchUp(_ sender: Any) {
        let index = pickerView.selectedRow(inComponent: 0)
        delegate?.didSelectState(
            state: StatePopoverViewController.states[index])
        self.dismiss(animated: true)
    }

    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
    
    /// Only have one component
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    /// The number of rows is the number of states
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return StatePopoverViewController.states.count
    }

    /// Set the state for the given row
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return StatePopoverViewController.states[row]
    }
}
