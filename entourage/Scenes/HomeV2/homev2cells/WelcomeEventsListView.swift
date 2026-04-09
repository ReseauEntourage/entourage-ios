import SwiftUI

enum WelcomeEventType {
    case firstStep
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

        if type == .firstStep {
            EventService.getWelcomeEvents(completion: completion)
        } else if type == .webinar {
            EventService.getWebinarEvents(completion: completion)
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
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    Button(action: {
                        onBack?()
                    }) {
                        Image("back_arrow")
                            .renderingMode(.template)
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                    }
                    
                    Text(viewModel.type == .firstStep ? "welcome_welcome_list_title".localized :
                            viewModel.type == .webinar ? "welcome_webinar_list_title".localized :
                            "welcome_papotages_list_title".localized)
                    .font(.custom("Quicksand-Bold", size: 24))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    
                    // Title & Subtitle
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.type == .firstStep ? "welcome_welcome_list_title".localized :
                                viewModel.type == .webinar ? "welcome_webinar_list_title".localized :
                                "welcome_papotages_list_title".localized)
                        .font(.custom("Quicksand-Bold", size: 18))
                        .foregroundColor(.black)
                        Spacer()
                    }
                    
                    Text(viewModel.type == .firstStep ? "welcome_welcome_list_subtitle".localized :
                            viewModel.type == .webinar ? "welcome_webinar_list_subtitle".localized :
                            "welcome_papotages_list_subtitle".localized)
                    .font(.custom("NunitoSans-Regular", size: 15))
                    .foregroundColor(.black)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
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
            HStack(alignment: .top, spacing: 10) {
                // Image
                ZStack(alignment: .bottomLeading) {
                    ZStack(alignment: .topLeading) {
                        if let urlString = event.metadata?.landscape_url ?? event.metadata?.portrait_url, !urlString.isEmpty, let url = URL(string: urlString) {
                            if #available(iOS 15.0, *) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image("ic_placeholder_event")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                                .frame(width: 94, height: 94)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            } else {
                                // Fallback on earlier versions
                                Image("ic_placeholder_event")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 94, height: 94)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        } else {
                            Image("ic_placeholder_event")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 94, height: 94)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        
                        if event.isCanceled() {
                            Color.black.opacity(0.5)
                                .frame(width: 94, height: 94)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        
                        // Entourage logo or Woman logo
                        if event.metadata?.reservedFemale == true {
                            Image("ic_entoutou_logo_woman")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .padding(.leading, 5)
                                .padding(.top, 68)
                        } else if event.author?.communityRoles?.contains("Équipe Entourage") == true || event.author?.communityRoles?.contains("Animateur Entourage") == true {
                            Image("ic_entoutou_logo_little")
                                .resizable()
                                .frame(width: 23, height: 23)
                                .padding(.leading, 5)
                                .padding(.top, 68)
                        }
                        
                        if event.isCanceled() {
                            Image("ic_event_canceled")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.leading, -4)
                                .padding(.top, -3)
                        }
                    }
                    
                    if event.isMember ?? false {
                        Text("  Inscrit.e  ")
                            .font(.custom("Quicksand-Bold", size: 12))
                            .foregroundColor(Color("orange_app"))
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.leading, 33)
                            .padding(.bottom, -10)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Title and Cancelled label
                    HStack(alignment: .top) {
                        Text(event.title)
                            .font(.custom("Quicksand-Bold", size: 15))
                            .foregroundColor(event.isCanceled() ? Color("gris_112") : .black)
                            .lineLimit(2)
                        Spacer()
                        if event.isCanceled() {
                            Text("- \("event_cancel_list".localized)")
                                .font(.custom("NunitoSans-Light", size: 13))
                                .foregroundColor(Color("gris_112"))
                        }
                    }
                    .padding(.top, 6)
                    
                    // Date
                    HStack(spacing: 8) {
                        Image("ic_event_list_date")
                            .resizable()
                            .frame(width: 10, height: 10)
                        
                        Text(event.startDateFormatted)
                            .font(.custom("NunitoSans-Light", size: 13))
                            .foregroundColor(Color("gris_112"))
                    }
                    .padding(.top, 4)
                    
                    // Place
                    HStack(spacing: 8) {
                        Image("ic_event_list_loc")
                            .resizable()
                            .frame(width: 11, height: 10)
                        Text(event.addressName ?? "")
                            .font(.custom("NunitoSans-Light", size: 13))
                            .foregroundColor(Color("gris_112"))
                            .lineLimit(1)
                    }
                    
                    // Members
                    if let membersCount = event.membersCount {
                        HStack(spacing: 8) {
                            Image("ic_event_list_user")
                                .resizable()
                                .frame(width: 10, height: 10)
                            
                            let memberString = membersCount > 1 ? String(format: "event_members_cell_list".localized, membersCount) : String(format: "event_member_cell_list".localized, membersCount)
                            Text(memberString)
                                .font(.custom("NunitoSans-Light", size: 13))
                                .foregroundColor(Color("gris_112"))
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 2)
                Spacer()
            }
            .padding(8)
            .padding(.horizontal, 8)
            .background(Color("BeigeClair"))
        }
    }
}
