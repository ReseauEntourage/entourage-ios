import SwiftUI
import CoreLocation
import GooglePlaces
import Combine

// MARK: - ViewModel
class EventCreatePhase3ViewModel: ObservableObject {
    var isInitializing: Bool = false

    @Published var isOnline: Bool = false {
        didSet {
            guard !isInitializing else { return }
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
            guard !isInitializing else { return }
            delegate?.addOnline(url: onlineUrl)
        }
    }

    @Published var placeName: String? = nil
    @Published var addressViewModel = AddressAutocompleteViewModel()
    @Published var isShowingSuggestions = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        addressViewModel.$query
            .receive(on: RunLoop.main)
            .sink { [weak self] newQuery in
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
            guard !isInitializing else { return }
            delegate?.addPlaceLimit(hasLimit: hasPlaceLimit, nbPlaces: hasPlaceLimit ? nbPlaceLimit : 0)
        }
    }
    
    @Published var nbPlaceLimitString: String = "" {
        didSet {
            guard !isInitializing else { return }
            let limit = Int(nbPlaceLimitString) ?? 0
            delegate?.addPlaceLimit(hasLimit: hasPlaceLimit, nbPlaces: limit)
        }
    }
    
    var nbPlaceLimit: Int {
        return Int(nbPlaceLimitString) ?? 0
    }

    @Published var isReservedFemale: Bool = false {
        didSet {
            guard !isInitializing else { return }
            delegate?.addReservedFemale(reserved: isReservedFemale)
        }
    }

    weak var delegate: EventCreateMainDelegate?
    var onShowSelectLocation: (() -> Void)?

    func load(currentEvent: Event?, delegate: EventCreateMainDelegate?) {
        isInitializing = true
        self.delegate = delegate
        if let currentEvent = currentEvent {
            if let eventIsOnline = currentEvent.isOnline { self.isOnline = eventIsOnline }
            self.onlineUrl = currentEvent.onlineEventUrl
            self.placeName = currentEvent.addressName
            if let name = self.placeName { self.addressViewModel.query = name }

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
        isInitializing = false
    }

    func setLocation(currentlocation: CLLocationCoordinate2D?, displayAddress: String?, backEndAddress: String?, googlePlace: GMSPlace?) {
        self.placeName = displayAddress
        self.isOnline = false
        self.onlineUrl = nil
        
        if let name = displayAddress {
            self.addressViewModel.query = name
        }

        DispatchQueue.main.async { [weak self] in
            self?.delegate?.addOnline(url: nil)
            self?.delegate?.addPlaceType(isOnline: false)
            self?.delegate?.addPlace(currentlocation: currentlocation, currentLocationName: backEndAddress, googlePlace: googlePlace)
        }
    }
}

// MARK: - View
struct EventCreatePhase3View: View {
    @ObservedObject var viewModel: EventCreatePhase3ViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 48) {
                // Section Lieu / Online
                VStack(alignment: .leading, spacing: 16) {
                    
                    // On utilise notre vue blindée pour le titre
                    MandatoryTitleView(titleKey: "eventCreatephase3_swiftUI_title_place")

                    HStack(spacing: 20) {
                        RadioButton(title: "event_create_phase3_presentiel".localized, isSelected: !viewModel.isOnline) { viewModel.isOnline = false }
                        RadioButton(title: "event_create_phase3_online".localized, isSelected: viewModel.isOnline) { viewModel.isOnline = true }
                    }

                    if viewModel.isOnline {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("event_create_phase3_placeholder_online".localized, text: Binding(
                                get: { viewModel.onlineUrl ?? "" },
                                set: { viewModel.onlineUrl = $0.isEmpty ? nil : $0 }
                            ))
                            .font(.custom("NunitoSans-Regular", size: 13))
                            .padding(.bottom, 8)
                            .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottom)
                            .keyboardType(.URL).autocapitalization(.none)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("event_create_phase3_placeholder_place".localized, text: $viewModel.addressViewModel.query)
                                .font(.custom("NunitoSans-Regular", size: 13))
                                .padding(.bottom, 8)
                                .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottom)
                                .disableAutocorrection(true)

                            if viewModel.isShowingSuggestions && !viewModel.addressViewModel.suggestions.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.addressViewModel.suggestions, id: \.placeID) { suggestion in
                                        Button(action: {
                                            let selectedText = suggestion.attributedFullText.string
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            
                                            viewModel.addressViewModel.getPlaceDetails(placeID: suggestion.placeID) { place, error in
                                                guard let place = place else { return }
                                                viewModel.setLocation(
                                                    currentlocation: place.coordinate,
                                                    displayAddress: selectedText,
                                                    backEndAddress: "",
                                                    googlePlace: place
                                                )
                                            }
                                        }) {
                                            VStack(alignment: .leading) {
                                                Text(suggestion.attributedFullText.string)
                                                    .font(.custom("NunitoSans-Regular", size: 13))
                                                    .foregroundColor(.black).padding(.vertical, 12)
                                                Divider()
                                            }
                                        }
                                    }
                                }
                                .background(Color.white).cornerRadius(8).shadow(radius: 4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Section Limite
                VStack(alignment: .leading, spacing: 16) {
                    
                    // On réutilise la même vue blindée pour la limite
                    MandatoryTitleView(titleKey: "eventCreatephase3_swiftUI_title_limit")
                    
                    HStack(spacing: 20) {
                        RadioButton(title: "event_create_phase3_limit_yes".localized, isSelected: viewModel.hasPlaceLimit) { viewModel.hasPlaceLimit = true }
                        RadioButton(title: "event_create_phase3_limit_no".localized, isSelected: !viewModel.hasPlaceLimit) {
                            viewModel.hasPlaceLimit = false
                            viewModel.nbPlaceLimitString = ""
                        }
                    }
                    if viewModel.hasPlaceLimit {
                        TextField("10", text: $viewModel.nbPlaceLimitString).keyboardType(.numberPad)
                            .overlay(Rectangle().frame(height: 1).padding(.top, 35), alignment: .bottom)
                    }
                }.padding(.horizontal, 20)

                // Section Reserved Female
                HStack {
                    Text("event_create_reserved_female_title".localized).font(.custom("NunitoSans-Bold", size: 15))
                    Spacer()
                    Toggle("", isOn: $viewModel.isReservedFemale).toggleStyle(SwitchToggleStyle(tint: Color("orange_app"))).scaleEffect(0.8)
                }.padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 32)
        }
    }
}

// MARK: - Subcomponents

/// Composant robuste pour gérer les titres obligatoires sans casser l'alignement SwiftUI
struct MandatoryTitleView: View {
    let titleKey: String
    
    var body: some View {
        (Text(titleKey.localized)
            .font(.custom("NunitoSans-Bold", size: 15))
        + Text(" ")
            .font(.custom("NunitoSans-Regular", size: 13)) // Fix: aide SwiftUI à lier les textes
        + Text("event_create_mandatory".localized)
            .font(.custom("NunitoSans-Regular", size: 13)))
        .multilineTextAlignment(.leading)
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
