import SwiftUI

enum WelcomeEventType {
    case webinar
    case papotages
}

class WelcomeEventsListViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading: Bool = true
    @Published var hasError: Bool = false

    let type: WelcomeEventType

    init(type: WelcomeEventType) {
        self.type = type
    }

    func fetchEvents() {
        self.isLoading = true
        self.hasError = false

        let completion: ([Event]?) -> Void = { [weak self] fetchedEvents in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let fetchedEvents = fetchedEvents {
                    self?.events = fetchedEvents
                } else {
                    self?.hasError = true
                }
            }
        }

        if type == .webinar {
            EventService.getWelcomeEvents(completion: completion)
        } else {
            EventService.getPapotagesEvents(completion: completion)
        }
    }
}

struct WelcomeEventsListView: View {
    @StateObject var viewModel: WelcomeEventsListViewModel
    var onBack: (() -> Void)?
    var onEventTapped: ((Event) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    onBack?()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(12)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            // Title & Subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.type == .webinar ? "welcome_webinar_list_title".localized : "welcome_papotages_list_title".localized)
                    .font(.custom("Quicksand-Bold", size: 24))
                    .foregroundColor(.black)

                Text(viewModel.type == .webinar ? "welcome_webinar_list_subtitle".localized : "welcome_papotages_list_subtitle".localized)
                    .font(.custom("NunitoSans-Regular", size: 15))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Content
            if viewModel.isLoading {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                Spacer()
            } else if viewModel.events.isEmpty || viewModel.hasError {
                Spacer()
                HStack {
                    Spacer()
                    Text("no_events_found".localized)
                        .font(.custom("NunitoSans-Regular", size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.events, id: \.uid) { event in
                            EventListCellWrap(event: event)
                                .frame(height: 140) // Approximation, adjusts natively if configured properly
                                .onTapGesture {
                                    onEventTapped?(event)
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            viewModel.fetchEvents()
        }
    }
}

// Wrapper to use the native HomeCellEvent or equivalent, but since HomeCellEvent is a UICollectionViewCell
// we will just build a native SwiftUI equivalent or wrap the existing view.
// Given time constraints, building a simple SwiftUI equivalent of HomeEventAdapter's cell.
struct EventListCellWrap: View {
    let event: Event

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Image
            ZStack(alignment: .topTrailing) {
                if let urlString = event.metadata?.landscape_url, let url = URL(string: urlString) {
                    if #available(iOS 15.0, *) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image("ic_event_placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                        .frame(width: 100, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        // Fallback on earlier versions
                    }
                } else {
                    Image("ic_event_placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Entourage logo or Woman logo
                if event.metadata?.reservedFemale == true {
                    Image("ic_entoutou_logo_woman")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(4)
                } else if event.author?.communityRoles?.contains("Équipe Entourage") == true || event.author?.communityRoles?.contains("Animateur Entourage") == true {
                    Image("ic_entourage_little")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(4)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(event.title)
                    .font(.custom("Quicksand-Bold", size: 15))
                    .foregroundColor(.black)
                    .lineLimit(2)

                // Date
                if let startDateString = event.metadata?.starts_at,
                   let startDate = Utils.getDateFromWSDateString(startDateString) {
                    
                    Text(Utils.formatEventDateTime(date: startDate))
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(.gray)
                }

                // Place
                if let address = event.metadata?.display_address {
                    let addressCondensed = address.components(separatedBy: ",").last ?? address
                    Text(addressCondensed.trimmingCharacters(in: .whitespaces))
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.vertical, 8)
            Spacer()
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
