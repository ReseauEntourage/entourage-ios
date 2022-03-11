//
//  GMSAuto.swift
//  entourage
//
//  Created by Jerome on 28/01/2022.
//

import GooglePlaces


class GMSAutoCompleteVC : GMSAutocompleteViewController {
    func setup(filterType:GMSPlacesAutocompleteTypeFilter) {
        let neBoundsCorner = CLLocationCoordinate2D(latitude: 50.77, longitude: 6.04)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: 43.57, longitude: -1.97)
        
        let filter = GMSAutocompleteFilter()
        filter.type = filterType
        filter.locationBias = GMSPlaceRectangularLocationOption(neBoundsCorner, swBoundsCorner)
        
        let fields = GMSPlaceField(arrayLiteral: [GMSPlaceField.name,GMSPlaceField.placeID,GMSPlaceField.formattedAddress,GMSPlaceField.coordinate])
        self.autocompleteFilter = filter
        self.placeFields = fields
        
        setupUI()
    }
    
    //TODO: Changer les couleurs de la page GMSAutocomplete si besoin ?
    private func setupUI() {
        
        self.primaryTextHighlightColor = ApplicationTheme.backgroundThemeColor
            self.primaryTextColor = self.secondaryTextColor;//TODO: a faire
            self.tintColor = ApplicationTheme.backgroundThemeColor
            
            // Color of typed text in the search bar.
        let searchBarTxtAttr = [NSAttributedString.Key.foregroundColor:ApplicationTheme.labelNavBarColor,
                                NSAttributedString.Key.font:UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = searchBarTxtAttr
        
        //    // Color of the placeholder text in the search bar prior to text entry.
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: ApplicationTheme.labelNavBarColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        
        //    // Color of the default search text.
        let attributedPlaceholder = NSAttributedString(string: "searchForAddress".localized,attributes: placeholderAttributes)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = attributedPlaceholder
        
        //    // To style the two image icons in the search bar (the magnifying glass
        //    // icon and the 'clear text' icon), replace them with different images.
        UISearchBar.appearance().setImage(UIImage.init(named: "whiteSearch"), for: .search, state: .normal)
        //    // Color of the in-progress spinner.
        UIActivityIndicatorView.appearance().color = ApplicationTheme.backgroundThemeColor
    }
    
}
