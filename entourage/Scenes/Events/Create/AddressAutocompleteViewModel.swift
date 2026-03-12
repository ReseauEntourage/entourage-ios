import Foundation
import Combine
import GooglePlaces
import CoreLocation

class AddressAutocompleteViewModel: NSObject, ObservableObject, GMSAutocompleteFetcherDelegate {
    @Published var suggestions: [GMSAutocompletePrediction] = []

    private var fetcher: GMSAutocompleteFetcher?
    private var cancellable: AnyCancellable?

    @Published var query: String = ""

    override init() {
        super.init()

        let neBoundsCorner = CLLocationCoordinate2D(latitude: 51.51, longitude: 6.40)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: 42.35, longitude: -5.14)

        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        filter.locationBias = GMSPlaceRectangularLocationOption(neBoundsCorner, swBoundsCorner)

        fetcher = GMSAutocompleteFetcher(filter: filter)
        fetcher?.delegate = self

        cancellable = $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newQuery in
                if newQuery.isEmpty {
                    self?.suggestions = []
                } else {
                    self?.fetcher?.sourceTextHasChanged(newQuery)
                }
            }
    }

    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        self.suggestions = predictions
    }

    func didFailAutocompleteWithError(_ error: Error) {
        print("Error fetching autocomplete predictions: \(error.localizedDescription)")
    }

    func getPlaceDetails(placeID: String, completion: @escaping (GMSPlace?, Error?) -> Void) {
        let fields: GMSPlaceField = [.name, .placeID, .formattedAddress, .coordinate, .addressComponents]
        GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { place, error in
            completion(place, error)
        }
    }
}
