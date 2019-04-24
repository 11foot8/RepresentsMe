//
//  CustomSearchBar.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit

protocol CustomSearchBarDelegate {
    func onSearchQuery(query:String)
    func onSearchClear()
    func onSearchBegin()
    func onSearchValueChanged()
    func multifunctionButtonPressed()
}

class CustomSearchBar: UIView, UITextFieldDelegate {
    // MARK: - Properties
    var delegate:CustomSearchBarDelegate?
    var searchBarText:String? {
        return searchBarTextField.text
    }

    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var searchBarTextField: UITextField!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var multifunctionButton: UIButton!

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
        let nib = UINib(nibName: "CustomSearchBar", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.lightGray.cgColor
        contentView.frame = bounds
        addSubview(contentView)

        searchBarView.layer.cornerRadius = 8
        searchBarView.clipsToBounds = true
        searchBarView.layer.borderWidth = 1.0
        searchBarView.layer.borderColor = UIColor.lightGray.cgColor

        searchBarTextField.layer.cornerRadius = 8
        searchBarTextField.clipsToBounds = true

        searchBarTextField.clearButtonMode = UITextField.ViewMode.always
        searchBarTextField.returnKeyType = .search

        searchBarTextField.delegate = self
    }

    // MARK: - Actions
    @IBAction func searchPrimaryAction(_ sender: Any) {
        searchBarTextField.resignFirstResponder()
        self.endEditing(true)
        guard delegate != nil else { return }
        let query = searchBarTextField.text!
        self.delegate?.onSearchQuery(query: query)
    }
    @IBAction func editingDidBegin(_ sender: Any) {
        delegate?.onSearchBegin()
    }
    @IBAction func searchValueChanged(_ sender: Any) {
//        guard delegate != nil else { return }
//        delegate?.onSearchValueChanged()
    }
    @IBAction func searchEditingDidEnd(_ sender: Any) {
    }
    @IBAction func multifunctionButtonTouchUp(_ sender: Any) {
        guard delegate != nil else { return }
        delegate?.multifunctionButtonPressed()
    }
    @IBAction func editingChanged(_ sender: Any) {
        guard delegate != nil else { return }
        delegate?.onSearchValueChanged()

    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        guard delegate != nil else { return false }
        self.delegate?.onSearchClear()
        return false
    }

    // Allows outside controllers to set the value of the query
    func setQuery(_ query:String?) {
        searchBarTextField.text = query
    }

    // MARK: - Accessors
    func startEditing() {
        searchBarTextField.becomeFirstResponder()
    }
    
    func setMultifunctionButton(icon:FontAwesome, enabled:Bool) {
        self.multifunctionButton.setTitle(String.fontAwesomeIcon(name: icon), for: .normal)
        self.multifunctionButton.isEnabled = enabled
    }

    override func resignFirstResponder() -> Bool {
        searchBarTextField.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool {
        searchBarTextField.becomeFirstResponder()
        return super.becomeFirstResponder()
    }

}
