//
//  PickerPopup.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/3/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit

protocol PickerPopupDelegate {
    func pickerDoneTouchUp(selection:String)
}

class PickerPopup: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Properties
    let pickerData = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT",
                      "DE", "DC", "FL", "GA", "HI", "ID", "IL",
                      "IN", "IA", "KS", "KT", "LA", "ME", "MD",
                      "MA", "MI", "MN", "MS", "MO", "MT", "NE",
                      "NV", "NH", "NJ", "NM", "NY", "NC", "ND",
                      "OH", "OK", "OR", "PA", "RI", "SC", "SD",
                      "TN", "TX", "UT", "VT", "VA", "WA", "WV",
                      "WI", "WY"]
    var delegate:PickerPopupDelegate?

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
        let nib = UINib(nibName: "PickerPopup", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)

    }

    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!

    @IBAction func doneTouchUp(_ sender: Any) {
        let selection = pickerData[pickerView.selectedRow(inComponent: 0)]
        delegate?.pickerDoneTouchUp(selection: selection)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

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

    public func setSelection(selectedValue:String) {
        if let selectedRow = pickerData.firstIndex(of: selectedValue) {
            pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        } else {
            // TODO: Handle invalid selected value
        }
    }

}
