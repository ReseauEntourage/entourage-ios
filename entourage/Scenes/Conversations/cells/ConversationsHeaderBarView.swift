//
//  ConversationsHeaderBarView.swift
//  entourage
//
//  Created by Clement entourage on 17/09/2026.
//

import SwiftUI

/// Straight (non-rounded) header bar: title + round filter button with active-pastille — EN-9490.
struct ConversationsHeaderBarView: View {

    var filterActive: Bool
    var onFilterTap: () -> Void

    var body: some View {
        HStack {
            Text("Messages_title".localized)
                .font(Font(ApplicationTheme.getFontQuickSandBold(size: 24)))
                .foregroundColor(.white)

            Spacer()

            Button(action: onFilterTap) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(UIColor.appOrange))
                        .frame(width: 52, height: 52)
                        .background(Circle().fill(Color.white))
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)

                    if filterActive {
                        Circle()
                            .fill(Color(red: 1, green: 0.16, blue: 0.16))
                            .frame(width: 15, height: 15)
                            .overlay(Circle().stroke(Color(UIColor.appOrange), lineWidth: 2.5))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
