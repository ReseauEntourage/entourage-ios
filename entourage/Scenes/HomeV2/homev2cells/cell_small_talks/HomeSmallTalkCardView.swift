import Foundation
import SwiftUI

// MARK: - State Definition
enum SmallTalkCardState {
    case initial
    case pending(count: Int)
    case active(activeCount: Int, pendingCount: Int, totalUnread: Int, avatars: [String])
}

// MARK: - View
struct HomeSmallTalkCardView: View {
    var state: SmallTalkCardState
    var actionStart: () -> Void
    var actionView: () -> Void
    
    var body: some View {
        switch state {
        case .initial:
            initialView
        case .pending(let count):
            pendingView(count: 1) //here force one because there is only one possible
        case .active(let activeCount, let pendingCount, let totalUnread, let avatars):
            activeView(
                activeCount: activeCount,
                pendingCount: pendingCount,
                totalUnread: totalUnread,
                avatars: avatars
            )
        }
    }
    
    // MARK: - Initial View (No active/pending discussions)
    private var initialView: some View {
        HStack(alignment: .top, spacing: 15) {
            Image("ic_puzzle_home")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("home_v2_small_talk_card_title".localized)
                    .font(.custom("Quicksand-Bold", size: 15))
                    .foregroundColor(.black)
                
                Text("home_v2_small_talk_card_subtitle".localized)
                    .font(.custom("NunitoSans-Regular", size: 14))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                Button(action: actionStart) {
                    Text("home_v2_small_talk_card_button".localized)
                        .font(.custom("Quicksand-Bold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .frame(height: 40)
                        .background(Color("orange_app"))
                        .cornerRadius(20)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(Color("BeigeClair2"))
        .cornerRadius(15)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
    
    // MARK: - Pending View (Only pending discussions)
        private func pendingView(count: Int) -> some View {
            HStack(alignment: .center, spacing: 12) {
                // 1. Icône de sablier (50x50 avec padding équivalent à 12dp)
                ZStack {
                    Circle()
                        .fill(Color("orange_app").opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "hourglass") // Remplacez par "ic_hourglass_small_talk" si c'est un asset custom
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26) // 50 - (12 * 2) = 26
                        .foregroundColor(Color("orange_app"))
                }
                
                // 2. Texte : Titre + Sous-titre
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bientôt de nouvelles rencontres")
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(.black)
                    
                    let matchingText = count > 1
                    ? String(format: "home_small_talk_pending_plural".localized, count)
                    : String(format: "home_small_talk_pending_singular".localized, count)
                    
                    Text(matchingText)
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(Color("grey_dark"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16) // Padding interne de la carte
            .background(Color("BeigeClair2"))
            .cornerRadius(15)
            .padding(.horizontal, 14) // Marges horizontales réduites de 1dp (14 au lieu de 15)
            .padding(.vertical, 10)   // Marges verticales réduites de 5dp (10 au lieu de 15)
        }
    
    private func activeView(activeCount: Int, pendingCount: Int, totalUnread: Int, avatars: [String]) -> some View {
        let totalMatches = activeCount + pendingCount
        
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 8) {  // Espacement horizontal réduit entre éléments
                // 1. Avatars (max 2)
                ZStack(alignment: .leading) {
                    ForEach(Array(avatars.prefix(2).enumerated()), id: \.offset) { index, avatarUrlStr in
                        Group {
                            if avatarUrlStr == "placeholder" {
                                Image("placeholder_user")
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                if #available(iOS 15.0, *) {
                                    AsyncImage(url: URL(string: avatarUrlStr)) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Image("placeholder_user")
                                            .resizable()
                                            .scaledToFill()
                                    }
                                } else {
                                    Image("placeholder_user")
                                        .resizable()
                                        .scaledToFill()
                                }
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("BeigeClair2"), lineWidth: 2))
                        .offset(x: CGFloat(index * 20))
                        .zIndex(Double(avatars.count - index))
                    }
                }
                .frame(width: CGFloat(40 + (min(avatars.count, 2) - 1) * 20), height: 40)
                
                // 2. Textes : Titre + Sous-titres
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vos discussions solidaires")
                        .font(.custom("Quicksand-Bold", size: 16))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    let activeText = activeCount > 1
                    ? String(format: "%d discussions actives", activeCount)
                    : String(format: "%d discussion active", activeCount)
                    Text(activeText)
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(Color("grey_dark"))
                    
                    if pendingCount > 0 {
                        Text(String(format: "+%d en cours de matching", pendingCount))
                            .font(.custom("NunitoSans-Regular", size: 13))
                            .foregroundColor(Color("orange_app"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 3. Bouton "Voir" + Badge
                ZStack(alignment: .topTrailing) {
                    Button(action: { actionView() }) {
                        Text("Voir")
                            .font(.custom("Quicksand-Bold", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("orange_app"))
                            .cornerRadius(20)
                    }
                    
                    if totalUnread > 0 {
                        Text("\(totalUnread)")
                            .font(.custom("Quicksand-Bold", size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .offset(x: 5, y: -5)
                    }
                }
            }
            .padding(.horizontal, 8)  // Marges latérales réduites pour le HStack
            
            if totalMatches < 3 && pendingCount == 0 {
                Button(action: { actionStart() }) {
                    Text(String(format: "home_small_talk_start_new".localized, totalMatches))
                        .font(.custom("NunitoSans-Regular", size: 14))
                        .foregroundColor(Color("orange_app"))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 12)  // Marges verticales réduites
        .padding(.horizontal, 10)  // Marges latérales globales réduites
        .background(Color("BeigeClair2"))
        .cornerRadius(15)
        .padding(.horizontal, 12)  // Padding externe réduit
        .padding(.vertical, 8)  // Padding vertical externe réduit
    }
}
