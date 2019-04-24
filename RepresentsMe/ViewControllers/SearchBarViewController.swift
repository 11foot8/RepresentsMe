//
//  SearchBarViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/23/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit

let UNWIND_SEARCH_BAR_SEGUE = "UnwindSegueToMapViewController"
let SEARCH_RESULT_CELL_IDENTIFIER = "searchResultCell"

enum SearchUnwindType {
    case backArrow
    case primaryButton
    case suggestedResult
}

class SearchBarViewController: UIViewController {
    // MARK: - Properties
    var unwindType:SearchUnwindType?    // To be accessed by mapView
    var searchRequest:MKLocalSearch.Request?
    var region:MKCoordinateRegion?
    private var _searchBarText:String?

    var searchBarText:String? {
        get {
            return self.customSearchBar.searchBarText
        }
        set(text) {
            _searchBarText = text
        }
    }
    var autocompleteResults:[Any] = []

    var searchResults = [MKLocalSearchCompletion]()
    var searchCompleter = MKLocalSearchCompleter()

    var workItem:DispatchWorkItem?   // Work item to update searchResults and reload table
    let resultsSemaphore =           // Semaphore to allow only one thread at a time to
        DispatchSemaphore(value: 1)  // modify searchResults and reload table

    // MARK: - Outlets
    @IBOutlet weak var customSearchBar: CustomSearchBar!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set search bar button appearance
        customSearchBar.setMultifunctionButton(icon: .chevronLeft, enabled: true)
        // Set search bar delegate
        customSearchBar.delegate = self
        // Begin editing in search bar
        let _ = customSearchBar.becomeFirstResponder()

        searchCompleter.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        // Hide keyboard when tableView interacted with
        tableView.keyboardDismissMode = .interactive
        tableView.keyboardDismissMode = .onDrag



    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let region = region {
            searchCompleter.region = region
        }

        customSearchBar.setQuery(_searchBarText ?? "")
        searchCompleter.queryFragment = customSearchBar.searchBarText!
    }

    // MARK: - Actions
    // MARK: - Methods
    func setSearchText(_ text:String?) {
        self.customSearchBar.setQuery(text)
        searchCompleter.queryFragment = customSearchBar.searchBarText!
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == UNWIND_SEARCH_BAR_SEGUE {
        }
    }

    /// Hide keyboard when tapping out of SearchBar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SearchBarViewController: CustomSearchBarDelegate {
    func onSearchQuery(query: String) {
        unwindType = .primaryButton
        searchRequest = MKLocalSearch.Request()
        searchRequest?.naturalLanguageQuery = searchBarText
        if let region = region { searchRequest?.region = region }
        performSegue(withIdentifier: UNWIND_SEARCH_BAR_SEGUE, sender: self)
    }

    func onSearchClear() {
        // TODO: Handle search clear
        searchCompleter.queryFragment = customSearchBar.searchBarText!
    }

    func onSearchBegin() {
        // TODO: Handle editing did begin

    }

    func onSearchValueChanged() {
        searchCompleter.queryFragment = customSearchBar.searchBarText!
    }

    func multifunctionButtonPressed() {
        // TODO: Transition back to mapview
        self.view.endEditing(true)
        unwindType = .backArrow
        performSegue(withIdentifier: UNWIND_SEARCH_BAR_SEGUE, sender: self)
    }
}

extension SearchBarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        resultsSemaphore.wait()
        self.view.endEditing(true)
        let row = indexPath.row
        guard row < searchResults.count else {
            resultsSemaphore.signal()
            return
        }
        let completion = searchResults[row]
        searchRequest = MKLocalSearch.Request(completion: completion)
        customSearchBar.setQuery(completion.title)
        resultsSemaphore.signal()
        unwindType = .suggestedResult
        performSegue(withIdentifier: UNWIND_SEARCH_BAR_SEGUE, sender: self)

        tableView.deselectRow(at: indexPath, animated: false)

    }
}

extension SearchBarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = searchResults.count
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SEARCH_RESULT_CELL_IDENTIFIER,
            for: indexPath) as! SearchBarTableViewCell

        let row = indexPath.row
        cell.searchResult = searchResults[row]
        cell.titleLabel.text = searchResults[row].title
        cell.subtitleLabel.text = searchResults[row].subtitle

        return cell
    }
}

extension SearchBarViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Cancel last pending autocomplete result update
        if let workItem = workItem {
            workItem.cancel()
        }
        workItem = DispatchWorkItem {
            self.resultsSemaphore.wait()
            self.searchResults = completer.results
            self.tableView.reloadData()
            self.resultsSemaphore.signal()
        }
        DispatchQueue.main.async(execute: workItem!)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let workItem = workItem {
            workItem.cancel()
        }
        workItem = DispatchWorkItem {
            self.resultsSemaphore.wait()
            self.searchResults = []
            self.tableView.reloadData()
            self.resultsSemaphore.signal()
        }
        DispatchQueue.main.async(execute: workItem!)
    }
}
