import Foundation
import UIKit
import MapKit

protocol MainFilterLocationCellDelegate {
    func onSearchIncreaseSize(size: CGFloat)
    func onAddressClick(coordinate: CLLocationCoordinate2D,adressTitle:String)
}

class MainFilterLocationCell: UITableViewCell, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate {
    
    // Outlets
    @IBOutlet weak var ui_textfield_location: UITextField!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var constraint_bottom: NSLayoutConstraint!
    
    // Variables
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var delegate: MainFilterLocationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLocationTextField()
        setupSuggestionsTableView()
        
        searchCompleter.delegate = self
    }
    
    func setupLocationTextField() {
        ui_textfield_location.delegate = self
    }
    
    func setupSuggestionsTableView() {
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        ui_tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        ui_tableview.isScrollEnabled = false
    }
    
    func configure(address:String) {
        self.ui_textfield_location.text = address
    }
    
    func dismissKeyboard() {
        self.endEditing(true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        searchCompleter.queryFragment = updatedText
        return true
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        ui_tableview.reloadData()
        updateTableViewHeight()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error fetching suggestions: \(error.localizedDescription)")
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let searchResult = searchResults[indexPath.row]
        cell.textLabel?.text = searchResult.title + ", " + searchResult.subtitle
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = searchResults[indexPath.row]
        ui_textfield_location.text = selectedResult.title + ", " + selectedResult.subtitle
        performSearch(for: selectedResult)
        searchResults.removeAll()
        ui_tableview.reloadData()
        updateTableViewHeight()
        dismissKeyboard()
    }
    
    
    // MARK: - Helper Methods
    
    func updateTableViewHeight() {
        let height = CGFloat(searchResults.count * 44 + 70) // 44 est la hauteur par défaut d'une cellule
        constraint_bottom.constant = height
        delegate?.onSearchIncreaseSize(size: height)
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    func performSearch(for completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, let mapItem = response.mapItems.first else {
                print("No matching location found")
                return
            }
            let coordinate = mapItem.placemark.coordinate
            self.delegate?.onAddressClick(coordinate: coordinate,adressTitle: self.ui_textfield_location.text ?? "" )
        }
    }
}
