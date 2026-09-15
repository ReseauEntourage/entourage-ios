//
//  EventLimitedPlacesModalView.swift
//  entourage
//
//  Created by Clement entourage on 15/09/2026.
//

import SwiftUI
import UIKit

/// New content for the "places limitées" registration modal (EN-9376/EN-9445).
struct EventLimitedPlacesModalView: View {

    var onRequestPlace: () -> Void
    var onDecline: () -> Void

    private let steps: [String] = [
        "event_limited_places_step1".localized,
        "event_limited_places_step2".localized,
        "event_limited_places_step3".localized
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDecline() }

            VStack(alignment: .leading, spacing: 16) {
                Text("event_limited_places_badge".localized)
                    .font(Font(ApplicationTheme.getFontNunitoBold(size: 12)))
                    .foregroundColor(Color(UIColor.appOrange))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.appOrangeLight_50))
                    .clipShape(Capsule())

                Text("event_limited_places_title".localized)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)))
                    .foregroundColor(.black)

                Text("event_limited_places_context".localized)
                    .font(Font(ApplicationTheme.getFontNunitoRegular(size: 14)))
                    .foregroundColor(Color(UIColor.appGris112))

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(Font(ApplicationTheme.getFontNunitoBold(size: 13)))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color(UIColor.appOrange))
                                .clipShape(Circle())

                            Text(step)
                                .font(Font(ApplicationTheme.getFontNunitoRegular(size: 14)))
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                Text("event_limited_places_nudge".localized)
                    .font(Font(ApplicationTheme.getFontNunitoRegularItalic(size: 13)))
                    .foregroundColor(Color(UIColor.appGris112))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.appBeigeLighter))
                    .cornerRadius(12)

                Button(action: onRequestPlace) {
                    Text("event_limited_places_cta_primary".localized)
                        .font(Font(ApplicationTheme.getFontQuickSandBold(size: 15)))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(UIColor.appOrange))
                        .clipShape(Capsule())
                }

                Button(action: onDecline) {
                    Text("event_limited_places_cta_secondary".localized)
                        .font(Font(ApplicationTheme.getFontNunitoBold(size: 14)))
                        .foregroundColor(Color(UIColor.appOrange))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            .padding(.bottom, 12)
            .background(Color.white)
            .clipShape(RoundedCorner(radius: 28, corners: [.topLeft, .topRight]))
        }
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

/// Presents `EventLimitedPlacesModalView` over the current context, matching the app's existing modal look.
final class EventLimitedPlacesModalViewController: UIHostingController<EventLimitedPlacesModalView> {

    init(onRequestPlace: @escaping () -> Void, onDecline: @escaping () -> Void) {
        super.init(rootView: EventLimitedPlacesModalView(onRequestPlace: onRequestPlace, onDecline: onDecline))
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        self.view.backgroundColor = .clear
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
