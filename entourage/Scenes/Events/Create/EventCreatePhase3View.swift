import SwiftUI
import CoreLocation
import GooglePlaces
import Combine

// MARK: - ViewModel (adresse) -

/// Gère l'autocomplétion de l'adresse (Google Places) et la cohérence entre le texte saisi
/// et le lieu enregistré dans le formulaire : si l'utilisateur retape l'adresse, le lieu
/// précédent est invalidé et il doit en choisir un nouveau dans les suggestions.
final class EventCreatePhase3ViewModel: ObservableObject {
    let address = AddressAutocompleteViewModel()
    @Published var isShowingSuggestions = false

    private weak var store: EventFormStore?
    private var cancellables = Set<AnyCancellable>()
    private var selectedText = ""

    init(store: EventFormStore) {
        self.store = store

        selectedText = store.values.addressName
        address.query = store.values.addressName

        address.$query
            .receive(on: RunLoop.main)
            .sink { [weak self] query in self?.queryChanged(query) }
            .store(in: &cancellables)

        // Adresse renseignée de l'extérieur (chargement d'un événement à modifier, brouillon).
        store.$values
            .map { $0.addressName }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] name in
                guard let self = self, !name.isEmpty, name != self.selectedText else { return }
                self.selectedText = name
                self.address.query = name
            }
            .store(in: &cancellables)
    }

    private func queryChanged(_ query: String) {
        if query == selectedText {
            isShowingSuggestions = false
            return
        }
        isShowingSuggestions = !query.isEmpty
        if let store = store, store.values.hasPlace {
            store.clearPlace()
            selectedText = ""
        }
    }

    func select(_ suggestion: GMSAutocompletePrediction) {
        let text = suggestion.attributedFullText.string
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        address.getPlaceDetails(placeID: suggestion.placeID) { [weak self] place, _ in
            guard let self = self, let place = place else { return }
            DispatchQueue.main.async {
                self.selectedText = text
                self.address.query = text
                self.isShowingSuggestions = false
                self.store?.setPlace(
                    name: text,
                    street: place.formattedAddress ?? place.name ?? "",
                    placeId: place.placeID,
                    latitude: place.coordinate.latitude,
                    longitude: place.coordinate.longitude
                )
            }
        }
    }
}

// MARK: - View -

/// Étape 3 « Où et pour qui ? » : présentiel / en ligne, adresse ou lien, places, cartes.
struct EventCreatePhase3View: View {
    @ObservedObject var store: EventFormStore
    @ObservedObject var viewModel: EventCreatePhase3ViewModel
    @ObservedObject var address: AddressAutocompleteViewModel

    init(store: EventFormStore, viewModel: EventCreatePhase3ViewModel) {
        self.store = store
        self.viewModel = viewModel
        self.address = viewModel.address
    }

    private var isOnline: Bool { store.values.isOnline }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                EventStepHeader(step: .location)

                modeSwitch
                    .padding(.bottom, 20)

                placeField
                    .padding(.bottom, 20)

                placeLimitField
                    .padding(.bottom, 22)

                Text((isOnline ? "event_form_section_public" : "event_form_section_access_public").localized)
                    .font(EventFormStyle.bold(13))
                    .foregroundColor(EventFormStyle.ink)
                    .padding(.bottom, 12)

                cards
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.onTapGesture { EventFormStyle.hideKeyboard() })
        }
        .background(Color.white)
    }

    // Bascule « En présentiel » / « En ligne » (orange, comme sur la maquette)
    private var modeSwitch: some View {
        HStack(spacing: 4) {
            modeButton(title: "event_create_phase3_presentiel".localized, isOn: !isOnline) { store.setOnline(false) }
            modeButton(title: "event_create_phase3_online".localized, isOn: isOnline) { store.setOnline(true) }
        }
        .padding(4)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(EventFormStyle.line, lineWidth: 1))
    }

    private func modeButton(title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(EventFormStyle.bold(14.5))
                .foregroundColor(isOn ? .white : EventFormStyle.ink2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(isOn ? EventFormStyle.accent : Color.clear)
                .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(addTraits: isOn ? [.isButton, .isSelected] : [.isButton])
    }

    @ViewBuilder
    private var placeField: some View {
        if isOnline {
            VStack(alignment: .leading, spacing: 0) {
                EventFormLabel(title: "event_form_link_label".localized, isRequired: true)
                EventFormTextField(
                    placeholder: "event_form_link_placeholder".localized,
                    text: store.binding(\.onlineUrl),
                    hasError: store.errors[.onlineUrl] != nil,
                    leadingSystemImage: "link",
                    keyboard: .URL,
                    autocapitalization: .none
                )
                .eventFormError(store.errors[.onlineUrl])
            }
        }
        else {
            VStack(alignment: .leading, spacing: 0) {
                EventFormLabel(title: "event_form_address_label".localized, isRequired: true)
                EventFormTextField(
                    placeholder: "event_form_address_placeholder".localized,
                    text: $address.query,
                    hasError: store.errors[.address] != nil,
                    leadingSystemImage: "mappin.and.ellipse",
                    autocapitalization: .none
                )
                if viewModel.isShowingSuggestions && !address.suggestions.isEmpty {
                    suggestionsList
                }
                else if let message = store.errors[.address] {
                    EventFormErrorText(message: message)
                }
            }
        }
    }

    private var suggestionsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(address.suggestions, id: \.placeID) { suggestion in
                Button(action: { viewModel.select(suggestion) }) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(suggestion.attributedFullText.string)
                            .font(EventFormStyle.regular(14))
                            .foregroundColor(EventFormStyle.ink)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 15)
                        Rectangle().fill(EventFormStyle.line2).frame(height: 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 2)
        .padding(.top, 8)
    }

    // Stepper de places : « Non », puis 1, 2, 3...
    private var placeLimitField: some View {
        VStack(alignment: .leading, spacing: 0) {
            EventFormLabel(title: "event_form_places_label".localized)
            HStack {
                Text("event_form_places_row".localized)
                    .font(EventFormStyle.regular(14))
                    .foregroundColor(EventFormStyle.ink2)
                Spacer()
                HStack(spacing: 18) {
                    stepperButton(systemImage: "minus", isEnabled: store.values.hasPlaceLimit) { store.decrementPlaceLimit() }
                        .accessibility(label: Text("event_form_places_less".localized))
                    Text(store.values.hasPlaceLimit ? "\(store.values.placeLimit)" : "event_create_phase3_limit_no".localized)
                        .font(EventFormStyle.bold(16))
                        .foregroundColor(EventFormStyle.ink)
                        .frame(minWidth: 36)
                    stepperButton(systemImage: "plus", isEnabled: true) { store.incrementPlaceLimit() }
                        .accessibility(label: Text("event_form_places_more".localized))
                }
            }
            .eventFormError(store.errors[.placeLimit])
        }
    }

    private func stepperButton(systemImage: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isEnabled ? EventFormStyle.ink : EventFormStyle.ink3)
                .frame(width: 40, height: 40)
                .overlay(Circle().stroke(EventFormStyle.line, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }

    // Cartes « fauteuil » (présentiel uniquement), « en famille », « réservé aux femmes ».
    // Fauteuil et famille sont gardées dans le formulaire / le brouillon / l'aperçu mais jamais envoyées à l'API.
    @ViewBuilder
    private var cards: some View {
        VStack(spacing: 11) {
            if !isOnline {
                EventSelectableCard(
                    symbolNames: ["figure.roll", "accessibility", "person.fill"],
                    title: "event_form_card_wheelchair_title".localized,
                    subtitle: "event_form_card_wheelchair_subtitle".localized,
                    isOn: store.values.isWheelchairAccessible,
                    action: { store.update { $0.isWheelchairAccessible.toggle() } }
                )
            }
            EventSelectableCard(
                symbolNames: ["figure.2.and.child.holdinghands", "person.2.fill"],
                title: "event_form_card_family_title".localized,
                subtitle: "event_form_card_family_subtitle".localized,
                isOn: store.values.isFamilyFriendly,
                action: { store.update { $0.isFamilyFriendly.toggle() } }
            )
            EventSelectableCard(
                symbolNames: ["figure.stand.dress", "person.fill"],
                title: "event_form_card_women_title".localized,
                isOn: store.values.isReservedFemale,
                action: { store.update { $0.isReservedFemale.toggle() } }
            )
        }
    }
}
