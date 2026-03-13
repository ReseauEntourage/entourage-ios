import SwiftUI

struct HomeEventCarouselView: View {
    let events: [Event]
    let onEventClick: ((Event) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(events, id: \.uid) { event in
                    Button(action: {
                        onEventClick?(event)
                    }) {
                        HomeEventCardView(event: event)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 240)
    }
}

struct HomeEventCardView: View {
    let event: Event

    var eventImageUrl: String {
        if let portrait = event.metadata?.portrait_url, !portrait.isEmpty {
            return portrait
        } else if let landscape = event.metadata?.landscape_url, !landscape.isEmpty {
            return landscape
        }
        return ""
    }

    var isAmbassador: Bool {
        if let roles = event.author?.communityRoles {
            return roles.contains("Équipe Entourage") || roles.contains("Animateur Entourage")
        }
        return false
    }

    var isReservedFemale: Bool {
        return event.metadata?.reservedFemale ?? false
    }

    var addressLastComponent: String {
        if let components = event.addressName?.split(separator: ","), let lastComponent = components.last {
            return String(lastComponent).trimmingCharacters(in: .whitespaces)
        }
        return event.addressName ?? ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header image
            ZStack(alignment: .top) {
                AsyncImage(url: URL(string: eventImageUrl)) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else if phase.error != nil {
                        Image("ic_placeholder_event").resizable()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width * 0.85 - 32, height: 120)
                .clipped()

                HStack(alignment: .top) {
                    // Badges
                    VStack(alignment: .leading) {
                        if event.isCanceled == true {
                            Text("event_canceled".localized)
                                .font(.custom("NunitoSans-Bold", size: 10))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color("appOrange"))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        } else {
                            Text("event_to_come".localized)
                                .font(.custom("NunitoSans-Bold", size: 10))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .foregroundColor(Color("appOrange"))
                                .cornerRadius(4)
                        }
                        Spacer()
                    }

                    Spacer()

                    if isReservedFemale {
                        Image("ic_entoutou_logo_woman")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if isAmbassador {
                        Image("ic_entoutou_logo_little")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(8)
            }

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title ?? "")
                    .font(.custom("NunitoSans-Bold", size: 16))
                    .foregroundColor(Color("appBlack"))
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image("ic_date_orange")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("appOrange"))
                        .frame(width: 14, height: 14)

                    Text(event.startDateFormatted)
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(Color("appGrey"))
                        .lineLimit(1)
                }

                HStack(spacing: 4) {
                    Image("ic_location_orange")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("appOrange"))
                        .frame(width: 14, height: 14)

                    Text(addressLastComponent)
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(Color("appGrey"))
                        .lineLimit(1)
                }

                // Interests Tag
                if let interests = event.interests, let firstInterest = interests.first {
                    HStack(spacing: 4) {
                        Image(getInterestIcon(for: firstInterest))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)

                        Text(TagsUtils.showTagTranslated(firstInterest))
                            .font(.custom("NunitoSans-Regular", size: 13))
                            .foregroundColor(Color("appGrey"))
                            .lineLimit(1)
                    }
                }
            }
            .padding(12)

            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.85 - 32, height: 260)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("appBeige"), lineWidth: 1)
        )
    }

    private func getInterestIcon(for interest: String) -> String {
        switch interest {
        case "activites": return "interest_activities"
        case "animaux": return "interest_animals"
        case "bien-etre": return "interest_wellness"
        case "cuisine": return "interest_cooking"
        case "culture": return "interest_art"
        case "jeux": return "interest_game"
        case "sport": return "interest_sport"
        case "nature": return "interest_nature"
        case "maraude": return "interest_maraude"
        default: return "interest_other"
        }
    }
}
