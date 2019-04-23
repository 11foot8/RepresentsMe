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
}

class CustomSearchBar: UIView, UITextFieldDelegate {
    // MARK: - Properties
    var delegate:CustomSearchBarDelegate?

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
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        contentView.frame = bounds
        addSubview(contentView)

        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true

        searchBarTextField.clearButtonMode = UITextField.ViewMode.always
        searchBarTextField.returnKeyType = .search

        searchBarTextField.delegate = self
    }

    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var searchBarTextField: UITextField!

    // MARK: - Actions
    @IBAction func searchPrimaryAction(_ sender: Any) {
        searchBarTextField.resignFirstResponder()
        guard delegate != nil else { return }
        let query = searchBarTextField.text!
        self.delegate?.onSearchQuery(query: query)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        textField.resignFirstResponder()
        guard delegate != nil else { return false }
        self.delegate?.onSearchClear()
        return false
    }

    // Allows outside controllers to set the value of the query
    func setQuery(_ query:String) {
        searchBarTextField.text = query
    }

}
