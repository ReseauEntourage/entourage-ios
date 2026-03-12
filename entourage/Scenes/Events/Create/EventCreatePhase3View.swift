import SwiftUI
import CoreLocation
import GooglePlaces
import Combine

class EventCreatePhase3ViewModel: ObservableObject {
    @Published var isOnline: Bool = false {
        didSet {
            if isOnline {
                placeName = nil
                addressViewModel.query = ""
                delegate?.addPlace(currentlocation: nil, currentLocationName: nil, googlePlace: nil)
                delegate?.addOnline(url: onlineUrl)
            } else {
                onlineUrl = nil
                delegate?.addOnline(url: nil)
            }
            delegate?.addPlaceType(isOnline: isOnline)
        }
    }
    
    @Published var onlineUrl: String? = nil {
        didSet {
            delegate?.addOnline(url: onlineUrl)
        }
    }

    @Published var placeName: String? = nil

    // Address autocomplete
    @Published var addressViewModel = AddressAutocompleteViewModel()
    @Published var isShowingSuggestions = false

    // Cancellation tracking
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Observe query changes to manage suggestion list visibility
        addressViewModel.$query
            .receive(on: RunLoop.main)
            .sink { [weak self] newQuery in
                // Only show suggestions if the query is non-empty AND we don't already have an exactly matching placeName
                // (which means they just selected something or we just loaded a place)
                if newQuery.isEmpty || newQuery == self?.placeName {
                    self?.isShowingSuggestions = false
                } else {
                    self?.isShowingSuggestions = true
                }
            }
            .store(in: &cancellables)
    }

    @Published var hasPlaceLimit: Bool = false {
        didSet {
            delegate?.addPlaceLimit(hasLimit: hasPlaceLimit, nbPlaces: hasPlaceLimit ? nbPlaceLimit : 0)
        }
    }
    
    @Published var nbPlaceLimitString: String = "" {
        didSet {
            let limit = Int(nbPlaceLimitString) ?? 0
            delegate?.addPlaceLimit(hasLimit: hasPlaceLimit, nbPlaces: limit)
        }
    }
    
    var nbPlaceLimit: Int {
        return Int(nbPlaceLimitString) ?? 0
    }

    @Published var isReservedFemale: Bool = false {
        didSet {
            delegate?.addReservedFemale(reserved: isReservedFemale)
        }
    }

    weak var delegate: EventCreateMainDelegate?
    var onShowSelectLocation: (() -> Void)?

    func load(currentEvent: Event?, delegate: EventCreateMainDelegate?) {
        self.delegate = delegate

        if let currentEvent = currentEvent {
            if let eventIsOnline = currentEvent.isOnline {
                self.isOnline = eventIsOnline
            }
            self.onlineUrl = currentEvent.onlineEventUrl
            self.placeName = currentEvent.addressName
            if let name = self.placeName {
                self.addressViewModel.query = name
            }

            if let metadata = currentEvent.metadata {
                if let limit = metadata.place_limit, limit > 0 {
                    self.hasPlaceLimit = true
                    self.nbPlaceLimitString = "\(limit)"
                } else if let hasLimit = metadata.hasPlaceLimit {
                    self.hasPlaceLimit = hasLimit
                }

                self.isReservedFemale = metadata.reservedFemale ?? false
            }
        }
    }

    func setLocation(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        self.placeName = currentLocationName
        self.isOnline = false
        self.onlineUrl = nil
        if let name = currentLocationName {
            self.addressViewModel.query = name
        }

        // Important: `isOnline = false` triggered its `didSet` block.
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.addOnline(url: nil)
            self?.delegate?.addPlaceType(isOnline: false)
            self?.delegate?.addPlace(currentlocation: currentlocation, currentLocationName: currentLocationName, googlePlace: googlePlace)
        }
    }
}

struct EventCreatePhase3View: View {
    @ObservedObject var viewModel: EventCreatePhase3ViewModel

    var body: some View {
        ScrollView {
            // Espacement global augmenté de nouveau (passage à 48dp)
            VStack(spacing: 48) {
                // MARK: Place / Online Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 4) {
                        Text("event_create_phase3_title".localized)
                            .font(.custom("NunitoSans-Bold", size: 15))
                            .foregroundColor(.black)
                        Text("event_create_mandatory".localized)
                            .font(.custom("NunitoSans-Regular", size: 13))
                            .foregroundColor(Color("color_legend"))
                    }

                    HStack(spacing: 20) {
                        RadioButton(title: "event_create_phase3_presentiel".localized, isSelected: !viewModel.isOnline) {
                            viewModel.isOnline = false
                        }
                        RadioButton(title: "event_create_phase3_online".localized, isSelected: viewModel.isOnline) {
                            viewModel.isOnline = true
                        }
                    }

                    if viewModel.isOnline {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                Text("event_create_phase3_title_online".localized)
                                    .font(.custom("NunitoSans-Bold", size: 15))
                                    .foregroundColor(.black)
                                Text("event_create_mandatory".localized)
                                    .font(.custom("NunitoSans-Regular", size: 13))
                                    .foregroundColor(Color("color_legend"))
                            }

                            TextField("event_create_phase3_placeholder_online".localized, text: Binding(
                                get: { viewModel.onlineUrl ?? "" },
                                set: { viewModel.onlineUrl = $0.isEmpty ? nil : $0 }
                            ))
                            .font(.custom("NunitoSans-Regular", size: 13))
                            .padding(.bottom, 8)
                            .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottom)
                            .foregroundColor(.black)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                Text("event_create_phase3_title_place".localized)
                                    .font(.custom("NunitoSans-Bold", size: 15))
                                    .foregroundColor(.black)
                                Text("event_create_mandatory".localized)
                                    .font(.custom("NunitoSans-Regular", size: 13))
                                    .foregroundColor(Color("color_legend"))
                            }

                            TextField("event_create_phase3_placeholder_place".localized, text: $viewModel.addressViewModel.query)
                                .font(.custom("NunitoSans-Regular", size: 13))
                                .padding(.bottom, 8)
                                .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottom)
                                .foregroundColor(.black)
                                .disableAutocorrection(true)

                            if viewModel.isShowingSuggestions && !viewModel.addressViewModel.suggestions.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.addressViewModel.suggestions, id: \.placeID) { suggestion in
                                        Button(action: {
                                            viewModel.addressViewModel.getPlaceDetails(placeID: suggestion.placeID) { place, error in
                                                guard let place = place else { return }
                                                viewModel.setLocation(
                                                    currentlocation: place.coordinate,
                                                    currentLocationName: place.formattedAddress ?? place.name,
                                                    googlePlace: place
                                                )
                                            }
                                        }) {
                                            VStack(alignment: .leading) {
                                                Text(suggestion.attributedFullText.string)
                                                    .font(.custom("NunitoSans-Regular", size: 13))
                                                    .foregroundColor(.black)
                                                    .multilineTextAlignment(.leading)
                                                    .padding(.vertical, 12)

                                                Divider()
                                            }
                                        }
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .padding(.top, 4)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

                // MARK: Limit Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 4) {
                        Text("event_create_phase3_title_limit".localized)
                            .font(.custom("NunitoSans-Bold", size: 15))
                            .foregroundColor(.black)
                        Text("event_create_mandatory".localized)
                            .font(.custom("NunitoSans-Regular", size: 13))
                            .foregroundColor(Color("color_legend"))
                    }

                    HStack(spacing: 20) {
                        RadioButton(title: "event_create_phase3_limit_yes".localized, isSelected: viewModel.hasPlaceLimit) {
                            viewModel.hasPlaceLimit = true
                        }
                        RadioButton(title: "event_create_phase3_limit_no".localized, isSelected: !viewModel.hasPlaceLimit) {
                            viewModel.hasPlaceLimit = false
                            viewModel.nbPlaceLimitString = ""
                        }
                    }

                    if viewModel.hasPlaceLimit {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                Text("event_create_phase3_title_nb_places".localized)
                                    .font(.custom("NunitoSans-Bold", size: 15))
                                    .foregroundColor(.black)
                                Text("event_create_mandatory".localized)
                                    .font(.custom("NunitoSans-Regular", size: 13))
                                    .foregroundColor(Color("color_legend"))
                            }

                            TextField("event_create_phase3_title_nb_places_placeholder".localized, text: $viewModel.nbPlaceLimitString)
                                .font(.custom("NunitoSans-Regular", size: 13))
                                .padding(.bottom, 8)
                                .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottom)
                                .foregroundColor(.black)
                                .keyboardType(.numberPad)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

                // MARK: Reserved Female Section
                HStack {
                    Text("event_create_reserved_female_title".localized)
                        .font(.custom("NunitoSans-Bold", size: 15))
                        .foregroundColor(.black)
                    Spacer()
                    Toggle("", isOn: $viewModel.isReservedFemale)
                        .toggleStyle(SwitchToggleStyle(tint: Color("orange_app")))
                        .scaleEffect(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 32) // Un peu d'air au-dessus du premier bloc
            .padding(.bottom, 40)
        }
    }
}

struct RadioButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(isSelected ? "ic_selector_on" : "ic_selector_off")
                    .resizable()
                    .frame(width: 20, height: 20)

                Text(title)
                    .font(.custom(isSelected ? "NunitoSans-Bold" : "NunitoSans-Regular", size: 15))
                    .foregroundColor(.black)
            }
        }
    }
}
