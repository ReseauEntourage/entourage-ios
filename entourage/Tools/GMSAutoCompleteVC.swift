//
//  GMSAuto.swift
//  entourage
//
//  Created by Jerome on 28/01/2022.
//

import GooglePlaces
import CoreLocation

class GMSAutoCompleteVC: GMSAutocompleteViewController {

    func setup(filterType: GMSPlacesAutocompleteTypeFilter) {
        // Borne géographique (France élargie)
        let neBoundsCorner = CLLocationCoordinate2D(latitude: 51.51, longitude: 6.40)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: 42.35, longitude: -5.14)

        let filter = GMSAutocompleteFilter()
        filter.type = filterType
        filter.locationBias = GMSPlaceRectangularLocationOption(neBoundsCorner, swBoundsCorner)
        // Sur les SDK récents : filter.countries = ["FR"] si tu veux limiter à la France

        self.autocompleteFilter = filter

        // 🔑 IMPORTANT : déclarer explicitement les champs dont on a besoin dans les autres écrans
        // - formattedAddress : pour tous les écrans
        // - coordinate      : pour les EventFilters / login / etc.
        // - addressComponents : pour EventFilters (city / postalCode)
        // - name / placeID  : utile si tu en as besoin ailleurs
        let fields: GMSPlaceField = [
            .name,
            .placeID,
            .formattedAddress,
            .coordinate,
            .addressComponents
        ]
        self.placeFields = fields

        setupUI()
    }

    //TODO: Changer les couleurs de la page GMSAutocomplete si besoin ?
    private func setupUI() {

        self.primaryTextHighlightColor = ApplicationTheme.backgroundThemeColor
        self.primaryTextColor = self.secondaryTextColor //TODO: à affiner si besoin
        self.tintColor = ApplicationTheme.backgroundThemeColor

        // Color of typed text in the search bar.
        let searchBarTxtAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: ApplicationTheme.labelNavBarColor,
            .font: UIFont.systemFont(ofSize: UIFont.systemFontSize)
        ]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = searchBarTxtAttr

        // Placeholder du search bar
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ApplicationTheme.labelNavBarColor,
            .font: UIFont.systemFont(ofSize: UIFont.systemFontSize)
        ]
        let attributedPlaceholder = NSAttributedString(
            string: "searchForAddress".localized,
            attributes: placeholderAttributes
        )
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = attributedPlaceholder

        // Icônes de la search bar
        UISearchBar.appearance().setImage(UIImage(named: "whiteSearch"), for: .search, state: .normal)

        // Couleur du spinner
        UIActivityIndicatorView.appearance().color = ApplicationTheme.backgroundThemeColor
    }
}
