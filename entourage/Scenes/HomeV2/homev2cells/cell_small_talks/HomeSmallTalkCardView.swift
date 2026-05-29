import Foundation
import SwiftUI

enum SmallTalkCardState {
    case initial
    case pending(count: Int)
    case active(activeCount: Int, pendingCount: Int, totalUnread: Int, avatars: [String])
}

struct HomeSmallTalkCardView: View {
    var state: SmallTalkCardState
    var actionStart: () -> Void
    var actionView: () -> Void
    
    var body: some View {
        switch state {
        case .initial:
            initialView
        case .pending(let count):
            pendingView(count: count)
        case .active(let activeCount, let pendingCount, let totalUnread, let avatars):
            activeView(activeCount: activeCount, pendingCount: pendingCount, totalUnread: totalUnread, avatars: avatars)
        }
    }
    
    private var initialView: some View {
        HStack(alignment: .top, spacing: 15) {
            Image("ic_puzzle_home")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
            
            VStack(alignment: .trailing, spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("home_v2_small_talk_card_title".localized)
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(.black)
                    
                    Text("home_v2_small_talk_card_subtitle".localized)
                        .font(.custom("NunitoSans-Regular", size: 14))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    actionStart()
                }) {
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
    
    private func pendingView(count: Int) -> some View {
        HStack(alignment: .center, spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color("orange_app").opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: "hourglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color("orange_app"))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("small_talk_title_waiting".localized)
                    .font(.custom("Quicksand-Bold", size: 15))
                    .foregroundColor(.black)
                
                let text = count > 1 ? String(format: "home_small_talk_pending_plural".localized, count) : String(format: "home_small_talk_pending_singular".localized, count)
                Text(text)
                    .font(.custom("NunitoSans-Regular", size: 14))
                    .foregroundColor(Color("blue_app"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(Color("BeigeClair2"))
        .cornerRadius(15)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
    
    private func activeView(activeCount: Int, pendingCount: Int, totalUnread: Int, avatars: [String]) -> some View {
        let totalMatches = activeCount + pendingCount
        
        return VStack(alignment: .leading, spacing: 15) {
            
            // --- BLOC DU HAUT (Avatars + Textes alignés à gauche + Bouton Voir) ---
            HStack(alignment: .top, spacing: 12) {
                
                // 1. Les Avatars
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
                                        image
                                            .resizable()
                                            .scaledToFill()
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
                        .frame(width: 34, height: 34)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("BeigeClair2"), lineWidth: 2))
                        .offset(x: CGFloat(index * 20))
                        .zIndex(Double(avatars.count - index))
                    }
                }
                .frame(width: CGFloat(34 + (min(avatars.count, 2) - 1) * 20), height: 34)
                .padding(.top, 4)
                
                // 2. Les Textes de statut
                VStack(alignment: .leading, spacing: 6) {
                    
                    // NOUVEAU: Regroupement du titre et du texte "pending" pour les coller
                    VStack(alignment: .leading, spacing: 2) {
                        Text("home_small_talk_active_title".localized)
                            .font(.custom("Quicksand-Bold", size: 15))
                            .foregroundColor(.black)
                            .lineLimit(2)
                        
                        let textActive = activeCount > 1 ? String(format: "home_small_talk_active_plural".localized, activeCount) : String(format: "home_small_talk_active_singular".localized, activeCount)
                        Text(textActive)
                            .font(.custom("NunitoSans-Regular", size: 14))
                            .foregroundColor(Color("blue_app"))

                        if pendingCount > 0 {
                            let textPending = pendingCount > 1 ? String(format: "home_small_talk_pending_plus_plural".localized, pendingCount) : String(format: "home_small_talk_pending_plus_singular".localized, pendingCount)
                            Text(textPending)
                                .font(.custom("NunitoSans-Regular", size: 14))
                                .foregroundColor(Color("orange_app"))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 3. Bouton Voir
                ZStack(alignment: .topTrailing) {
                    Button(action: {
                        actionView()
                    }) {
                        Text("home_small_talk_view_button".localized)
                            .font(.custom("Quicksand-Bold", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .frame(height: 34)
                            .background(Color("orange_app"))
                            .cornerRadius(17)
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
            
            // --- BLOC DU BAS (Bouton de création centré sur la largeur complète) ---
            if totalMatches < 3 && pendingCount == 0 {
                Button(action: {
                    actionStart()
                }) {
                    Text(String(format: "home_small_talk_start_new".localized, totalMatches))
                        .font(.custom("NunitoSans-Regular", size: 14))
                        .foregroundColor(Color("orange_app"))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 5)
            }
            
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(Color("BeigeClair2"))
        .cornerRadius(15)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
}
