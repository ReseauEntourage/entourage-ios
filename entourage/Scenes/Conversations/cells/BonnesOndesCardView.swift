//
//  BonnesOndesCardView.swift
//  entourage
//
//  Created by Clement entourage on 16/09/2026.
//

import SwiftUI

/// "Rejoindre une discussion solidaire" feature card, styled after the reference mockup — EN-9487/EN-9490.
struct BonnesOndesCardView: View {

    var onDiscuterTap: () -> Void

    var body: some View {
        HStack(spacing: 13) {
            Text("🧩")
                .font(.system(size: 23))
                .frame(width: 48, height: 48)
                .background(Color(UIColor.appTagActBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text("conversation_bonnes_ondes_title".localized)
                    .font(Font(ApplicationTheme.getFontNunitoSemiBold(size: 14)))
                    .foregroundColor(.black)
                Text("conversation_bonnes_ondes_subtitle".localized)
                    .font(Font(ApplicationTheme.getFontNunitoRegular(size: 12)))
                    .foregroundColor(Color(UIColor.appGris112))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Button(action: onDiscuterTap) {
                Text("conversation_bonnes_ondes_cta".localized)
                    .font(Font(ApplicationTheme.getFontNunitoBold(size: 12)))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(Color(UIColor.appOrange))
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(UIColor.appBeige), lineWidth: 1.5)
        )
    }
}
