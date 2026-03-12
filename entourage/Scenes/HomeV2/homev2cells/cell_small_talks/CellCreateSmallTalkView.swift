//
//  CellCreateSmallTalkView.swift
//  entourage
//
//  Created by clément perrousset on 12/03/2026.
//

import Foundation
import SwiftUI

struct CellCreateSmallTalkView: View {
    // Action passée par le parent lors du clic sur le bouton
    var action: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Image correspondante au XIB
            Image("ic_puzzle_home")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)

            VStack(alignment: .trailing, spacing: 15) {
                // Titre et Sous-titre
                VStack(alignment: .leading, spacing: 4) {
                    Text("home_v2_small_talk_card_title".localized)
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(.black)
                    
                    Text("home_v2_small_talk_card_subtitle".localized)
                        .font(.custom("NunitoSans-Regular", size: 13))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Bouton Commencer (Style mis à jour)
                Button(action: {
                    action()
                }) {
                    Text("home_v2_small_talk_card_button".localized)
                        .font(.custom("Quicksand-Bold", size: 14)) // Taille passée à 14
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .frame(height: 40)
                        .background(Color("orange_app")) 
                        .cornerRadius(20)
                }
            }
        }
        .padding(20)
        .background(Color("BeigeClair2"))
        .cornerRadius(10)
    }
}
