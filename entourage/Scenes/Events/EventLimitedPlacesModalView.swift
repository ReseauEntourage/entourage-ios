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

    /// Renders `**bold**` markdown spans in localized copy without changing the surrounding text color.
    private func markdownText(_ string: String) -> Text {
        if #available(iOS 15, *), let attributed = try? AttributedString(markdown: string) {
            return Text(attributed)
        }
        return Text(string.replacingOccurrences(of: "**", with: ""))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDecline() }

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    Text("event_limited_places_badge".localized)
                        .font(Font(ApplicationTheme.getFontNunitoBold(size: 12)))
                        .foregroundColor(Color(UIColor.appOrangeDark))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.appBeigeLighter))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Spacer()

                    Button(action: onDecline) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(UIColor.appOrange))
                    }
                }

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

                            markdownText(step)
                                .font(Font(ApplicationTheme.getFontNunitoRegular(size: 14)))
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 35)
                        .fill(Color(UIColor.appBeigeClair))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(Color(UIColor(hexString: "#CDCDCD")), lineWidth: 1)
                )

                markdownText("event_limited_places_nudge".localized)
                    .font(Font(ApplicationTheme.getFontNunitoRegular(size: 13)))
                    .foregroundColor(Color(UIColor.appGris112))
                    .fixedSize(horizontal: false, vertical: true)

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
                        .foregroundColor(Color(UIColor.appGris112))
                        .underline()
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 26)
            .padding(.bottom, 22)
            .background(Color.white)
            .clipShape(RoundedCorner(radius: 35, corners: [.topLeft, .topRight]))
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
