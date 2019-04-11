//
//  PickerPopoverViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/3/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

protocol PickerPopoverViewControllerDelegate {
    func pickerDoneTouchUp(selection:String)
}

class PickerPopoverViewController: PopoverViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Properties
    let pickerData = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT",
                      "DE", "DC", "FL", "GA", "HI", "ID", "IL",
                      "IN", "IA", "KS", "KT", "LA", "ME", "MD",
                      "MA", "MI", "MN", "MS", "MO", "MT", "NE",
                      "NV", "NH", "NJ", "NM", "NY", "NC", "ND",
                      "OH", "OK", "OR", "PA", "RI", "SC", "SD",
                      "TN", "TX", "UT", "VT", "VA", "WA", "WV",
                      "WI", "WY"]
    var delegate:PickerPopoverViewControllerDelegate?
    var selectedValue:String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self

        if selectedValue != nil {
            if let selectedRow = pickerData.firstIndex(of: selectedValue!) {
                pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            } else {
                // TODO: Handle invalid selected value
            }
        }

    }

    // MARK: - Outlets
    @IBOutlet weak var pickerView: UIPickerView!

    // MARK: - Actions
    @IBAction func doneTouchUp(_ sender: Any) {
        let selection = pickerData[pickerView.selectedRow(inComponent: 0)]
        delegate?.pickerDoneTouchUp(selection: selection)
        self.dismiss(animated: true)
    }

    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
