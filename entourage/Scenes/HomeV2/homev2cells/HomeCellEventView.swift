import SwiftUI
import SDWebImageSwiftUI

struct HomeCellEventView: View {
    var event: Event
    var action: () -> Void

    var imageUrl: URL? {
        if let urlStr = event.metadata?.portrait_url, !urlStr.isEmpty {
            return URL(string: urlStr)
        }
        if let urlStr = event.metadata?.landscape_url, !urlStr.isEmpty {
            return URL(string: urlStr)
        }
        return nil
    }

    var isAmbassador: Bool {
        if let author = event.author, let roles = author.communityRoles {
            return roles.contains("Équipe Entourage") || roles.contains("Animateur Entourage")
        }
        return false
    }

    var isReservedFemale: Bool {
        return event.metadata?.reservedFemale ?? false
    }

    var addressPlace: String {
        let addressComponents = event.addressName?.split(separator: ",")
        if let lastComponent = addressComponents?.last {
            return String(lastComponent).trimmingCharacters(in: .whitespaces)
        }
        return event.addressName ?? ""
    }

    var interestText: String {
        if let interests = event.interests, interests.count > 0, let firstInterest = interests.first {
            return TagsUtils.showTagTranslated(firstInterest)
        }
        return "Autre"
    }

    var interestImageName: String {
        if let interests = event.interests, interests.count > 0, let firstInterest = interests.first {
            switch firstInterest {
            case "activites": return "interest_activities"
            case "animaux": return "interest_animals"
            case "bien-etre": return "interest_wellness"
            case "cuisine": return "interest_cooking"
            case "culture": return "interest_art"
            case "jeux": return "interest_game"
            case "sport": return "interest_sport"
            case "nature": return "interest_nature"
            case "marauding": return "interest_nomad"
            default: return "interest_others"
            }
        }
        return "interest_others"
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    if let url = imageUrl {
                        WebImage(url: url)
                            .resizable()
                            .placeholder {
                                Image("ic_placeholder_event")
                                    .resizable()
                            }
                            .indicator(.activity)
                            .scaledToFill()
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        Image("ic_placeholder_event")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    }

                    HStack {
                        if isReservedFemale {
                            Image("ic_entoutou_logo_woman")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(8)
                        } else if isAmbassador {
                            Image("ic_entoutou_logo_little")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(8)
                        }
                        Spacer()
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(event.startDateFormatted)
                        .font(.custom("NunitoSans-Bold", size: 12))
                        .foregroundColor(Color("appOrange"))
                        .lineLimit(1)

                    Text(event.title)
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(Color("black_app"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    HStack(spacing: 5) {
                        Image("ic_location") // Ensure icon exists
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundColor(Color("grey"))

                        Text(addressPlace)
                            .font(.custom("NunitoSans-Regular", size: 12))
                            .foregroundColor(Color("grey"))
                            .lineLimit(1)
                    }

                    HStack(spacing: 5) {
                        Image(interestImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)

                        Text(interestText)
                            .font(.custom("NunitoSans-Regular", size: 12))
                            .foregroundColor(Color("grey"))
                            .lineLimit(1)
                    }
                }
                .padding(10)
            }
            .frame(width: 160, height: 215)
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("appBeige"), lineWidth: 1)
            )
        }
    }
}
