import Foundation
import SwiftUI

struct CellCreateSmallTalkView: View {
    // Action passée par le parent lors du clic sur le bouton
    var action: () -> Void

    var body: some View {
        // On aligne vers le haut (.top) pour que l'image suive le titre
        HStack(alignment: .top, spacing: 15) {
            // Image correspondante au XIB
            Image("ic_puzzle_home")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70) // Légèrement agrandie pour coller à la maquette

            VStack(alignment: .trailing, spacing: 15) {
                // Titre et Sous-titre
                VStack(alignment: .leading, spacing: 6) {
                    Text("home_v2_small_talk_card_title".localized)
                        .font(.custom("Quicksand-Bold", size: 18))
                        .foregroundColor(.black)
                    
                    Text("home_v2_small_talk_card_subtitle".localized)
                        .font(.custom("NunitoSans-Regular", size: 14))
                        .foregroundColor(.black)
                        // Force le texte à aller à la ligne au lieu d'être tronqué
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Bouton Commencer
                Button(action: {
                    action()
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
        // 1. MARGES INTERNES (Espace entre le texte/image et le bord de la carte)
        .padding(20)
        
        // 2. FOND ET STYLE DE LA CARTE
        .background(Color("BeigeClair2"))
        .cornerRadius(15) // Un poil plus arrondi pour correspondre à ton image
        
        // 3. MARGES EXTERNES (Fait "flotter" la carte au milieu de la cellule)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
}
