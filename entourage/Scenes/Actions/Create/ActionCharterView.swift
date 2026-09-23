//
//  ActionCharterView.swift
//  entourage
//
//  Created by Claude on 16/09/2026.
//

import SwiftUI

struct ActionCharterView: View {

    let isContrib: Bool
    let onAccept: () -> Void
    let onReadFullCharter: () -> Void

    @State private var contentFrame: CGRect = .zero
    @State private var viewportHeight: CGFloat = 0

    private let scrollSpace = "action_charter_scroll"
    private let sheetColor = Color(UIColor.appBeigeClair)

    // EN-9620 : le lien "Lire la charte complète" et le CTA terminent le contenu scrollable
    // (plus de footer sticky rapporté, et il faut atteindre le bas pour valider). Un fondu en
    // haut/bas de la zone scrollable évite que le contenu soit coupé net.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                bannerView
                examplesSection
                limitsSection
                if !isContrib {
                    respectSection
                }
                if isContrib {
                    spiritView
                }
                ctaView
                    .padding(.top, 10)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 14)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: CharterContentFrameKey.self, value: proxy.frame(in: .named(scrollSpace)))
                }
            )
        }
        .coordinateSpace(name: scrollSpace)
        .background(
            GeometryReader { proxy in
                Color.clear.preference(key: CharterViewportHeightKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(CharterContentFrameKey.self) { contentFrame = $0 }
        .onPreferenceChange(CharterViewportHeightKey.self) { viewportHeight = $0 }
        .overlay(scrollFade(fromTop: true).opacity(canScrollBackward ? 1 : 0), alignment: .top)
        .overlay(scrollFade(fromTop: false).opacity(canScrollForward ? 1 : 0), alignment: .bottom)
        .background(sheetColor)
    }

    private var canScrollBackward: Bool {
        contentFrame.minY < -1
    }

    private var canScrollForward: Bool {
        viewportHeight > 0 && contentFrame.maxY > viewportHeight + 1
    }

    /// Masque dégradé (couleur de la feuille → transparent) posé sur un bord de la zone scrollable.
    private func scrollFade(fromTop: Bool) -> some View {
        LinearGradient(colors: fromTop ? [sheetColor, sheetColor.opacity(0)] : [sheetColor.opacity(0), sheetColor],
                       startPoint: .top, endPoint: .bottom)
            .frame(height: 26)
            .allowsHitTesting(false)
    }

    // MARK: - Banner

    private var bannerView: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(isContrib ? "🤝" : "🙋")
                .font(.system(size: 22))
                .frame(width: 42, height: 42)
                .background(Color(UIColor.appOrange))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(isContrib ? "action_charter_contrib_eyebrow".localized : "action_charter_demand_eyebrow".localized)
                    .font(Font(ApplicationTheme.getFontQuickSandBold(size: 10.5)))
                    .textCase(.uppercase)
                    .foregroundColor(Color(UIColor.appOrangeDark))

                Text(isContrib ? "action_charter_contrib_title".localized : "action_charter_demand_title".localized)
                    .font(Font(ApplicationTheme.getFontQuickSandBold(size: 16)))
                    .foregroundColor(.black)
                    .lineSpacing(1)

                Text(isContrib ? "action_charter_contrib_subtitle".localized : "action_charter_demand_subtitle".localized)
                    .font(Font(ApplicationTheme.getFontNunitoRegular(size: 13)))
                    .foregroundColor(Color(UIColor.appGris112))
                    .lineSpacing(2)
            }
        }
        .padding(14)
        .background(
            LinearGradient(colors: [Color("very_light_orange"), Color(UIColor.appOrangeLight_50)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
    }

    // MARK: - Examples

    private var examplesSection: some View {
        sectionContainer(dot: "✓", dotBackground: Color(UIColor.appGreenLogout).opacity(0.18), dotColor: Color(UIColor.appGreenLogout), title: "action_charter_examples_title".localized) {
            cardContainer {
                let items = examples
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    if index > 0 {
                        Divider().padding(.leading, 42)
                    }
                    itemRow(icon: item.icon, text: item.text)
                }
            }
        }
    }

    private var examples: [(icon: String, text: String)] {
        if isContrib {
            return [
                (icon: "🧺", text: "action_charter_contrib_example_1".localized),
                (icon: "☕", text: "action_charter_contrib_example_2".localized),
                (icon: "🗣️", text: "action_charter_contrib_example_3".localized),
                (icon: "🧥", text: "action_charter_contrib_example_4".localized)
            ]
        } else {
            return [
                (icon: "🧥", text: "action_charter_demand_example_1".localized),
                (icon: "🧺", text: "action_charter_demand_example_2".localized),
                (icon: "☕", text: "action_charter_demand_example_3".localized)
            ]
        }
    }

    // MARK: - Limits

    private var limitsSection: some View {
        sectionContainer(dot: "!", dotBackground: Color(UIColor.appOrangeLight_50), dotColor: Color(UIColor.appOrangeDark), title: "action_charter_limits_title".localized) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(limits.enumerated()), id: \.offset) { _, text in
                    HStack(alignment: .top, spacing: 9) {
                        Text("✕")
                            .font(Font(ApplicationTheme.getFontQuickSandBold(size: 12.5)))
                            .foregroundColor(Color(UIColor.appOrangeDark))
                        Text(text)
                            .font(Font(ApplicationTheme.getFontNunitoRegular(size: 12.5)))
                            .foregroundColor(Color(UIColor.appGris112))
                            .lineSpacing(1)
                    }
                }

                Text(limitFooter)
                    .font(Font(ApplicationTheme.getFontNunitoRegular(size: 12)))
                    .foregroundColor(Color(UIColor.appGris112))
                    .lineSpacing(1)
                    .padding(.top, 7)
                    .overlay(
                        Rectangle()
                            .fill(Color(UIColor.appOrangeLight))
                            .frame(height: 1)
                            .padding(.top, 0),
                        alignment: .top
                    )
            }
            .padding(14)
            .background(Color("very_light_orange"))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(UIColor.appOrangeLight_70), lineWidth: 1)
            )
            .cornerRadius(16)
        }
    }

    private var limits: [String] {
        if isContrib {
            return [
                "action_charter_contrib_limit_1".localized,
                "action_charter_contrib_limit_2".localized,
                "action_charter_contrib_limit_3".localized,
                "action_charter_contrib_limit_4".localized
            ]
        } else {
            return [
                "action_charter_demand_limit_1".localized,
                "action_charter_demand_limit_2".localized,
                "action_charter_demand_limit_3".localized,
                "action_charter_demand_limit_4".localized
            ]
        }
    }

    private var limitFooter: String {
        isContrib ? "action_charter_contrib_limit_footer".localized : "action_charter_demand_limit_footer".localized
    }

    // MARK: - Respect (demande only)

    private var respectSection: some View {
        sectionContainer(dot: "♥", dotBackground: Color(UIColor.appOrangeLight_50), dotColor: Color(UIColor.appOrangeDark), title: "action_charter_respect_title".localized) {
            cardContainer {
                let items: [(icon: String, text: String)] = [
                    (icon: "🤲", text: "action_charter_demand_respect_1".localized),
                    (icon: "🔒", text: "action_charter_demand_respect_2".localized),
                    (icon: "🤝", text: "action_charter_demand_respect_3".localized)
                ]
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    if index > 0 {
                        Divider().padding(.leading, 42)
                    }
                    itemRow(icon: item.icon, text: item.text)
                }
            }
        }
    }

    // MARK: - Spirit (contribution only)

    private var spiritView: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("✨").font(.system(size: 18))
            Text("action_charter_contrib_spirit".localized)
                .font(Font(ApplicationTheme.getFontNunitoBold(size: 12.5)))
                .foregroundColor(Color(UIColor.appGreenLogout))
                .lineSpacing(2)
        }
        .padding(13)
        .background(Color("green_light"))
        .cornerRadius(16)
    }

    // MARK: - CTA (fin du contenu scrollable)

    private var ctaView: some View {
        VStack(spacing: 8) {
            Button(action: onReadFullCharter) {
                Text("action_charter_read_full_link".localized)
                    .font(Font(ApplicationTheme.getFontNunitoBold(size: 11.5)))
                    .foregroundColor(Color(UIColor.appOrangeDark))
                    .underline()
            }

            Button(action: onAccept) {
                Text("accept_charte".localized)
                    .font(Font(ApplicationTheme.getFontQuickSandBold(size: 15)))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
            }
            .background(Color(UIColor.appOrange))
            .cornerRadius(32)
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Shared building blocks

    @ViewBuilder
    private func sectionContainer<Content: View>(dot: String, dotBackground: Color, dotColor: Color, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(dot)
                    .font(Font(ApplicationTheme.getFontQuickSandBold(size: 11.5)))
                    .foregroundColor(dotColor)
                    .frame(width: 20, height: 20)
                    .background(dotBackground)
                    .clipShape(Circle())

                Text(title)
                    .font(Font(ApplicationTheme.getFontQuickSandBold(size: 13.5)))
                    .foregroundColor(.black)
            }
            content()
        }
    }

    @ViewBuilder
    private func cardContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .background(Color.white)
        .cornerRadius(16)
    }

    private func itemRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon)
                .font(.system(size: 16))
                .frame(width: 20)
            Text(text)
                .font(Font(ApplicationTheme.getFontNunitoRegular(size: 12.5)))
                .foregroundColor(.black)
                .lineSpacing(1)
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
    }
}

private struct CharterContentFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

private struct CharterViewportHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
