//
//  ConversationFilterModalView.swift
//  entourage
//
//  Created by Clement entourage on 15/09/2026.
//

import SwiftUI
import UIKit

/// Multi-select filter sheet for the Discussions list (types: individuelles / événements / bonnes ondes) — EN-9487.
struct ConversationFilterModalView: View {

    @State private var selected: Set<String>
    var onApply: (Set<String>) -> Void
    var onReset: () -> Void
    var onClose: () -> Void

    private let options: [(id: String, title: String, subtitle: String)] = [
        ("Conversation", "conversation_filter_individual_title".localized, "conversation_filter_individual_subtitle".localized),
        ("Outing", "conversation_filter_events_title".localized, "conversation_filter_events_subtitle".localized),
        ("Smalltalk", "conversation_filter_smalltalk_title".localized, "conversation_filter_smalltalk_subtitle".localized)
    ]

    init(initialSelection: Set<String>, onApply: @escaping (Set<String>) -> Void, onReset: @escaping () -> Void, onClose: @escaping () -> Void) {
        _selected = State(initialValue: initialSelection)
        self.onApply = onApply
        self.onReset = onReset
        self.onClose = onClose
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(alignment: .leading, spacing: 18) {
                Text("conversation_filter_title".localized)
                    .font(Font(UIFont(name: "Quicksand-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)))
                    .foregroundColor(.black)

                VStack(spacing: 12) {
                    ForEach(options, id: \.id) { option in
                        Button(action: { toggle(option.id) }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: selected.contains(option.id) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(selected.contains(option.id) ? Color(UIColor.appOrange) : Color(UIColor.appGris112))
                                    .font(.system(size: 20))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.title)
                                        .font(Font(ApplicationTheme.getFontNunitoBold(size: 14)))
                                        .foregroundColor(.black)
                                    Text(option.subtitle)
                                        .font(Font(ApplicationTheme.getFontNunitoRegular(size: 12)))
                                        .foregroundColor(Color(UIColor.appGris112))
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(spacing: 12) {
                    Button(action: { onReset(); onClose() }) {
                        Text("btn_main_filter_cancel_title".localized)
                            .font(Font(ApplicationTheme.getFontNunitoBold(size: 14)))
                            .foregroundColor(Color(UIColor.appOrange))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(Capsule().stroke(Color(UIColor.appOrange), lineWidth: 1.5))
                    }

                    Button(action: { onApply(selected); onClose() }) {
                        Text("btn_main_filter_validate_title".localized)
                            .font(Font(ApplicationTheme.getFontQuickSandBold(size: 14)))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(UIColor.appOrange))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 6)
            }
            .padding(20)
            .padding(.bottom, 12)
            .background(Color.white)
            .clipShape(RoundedCorner(radius: 28, corners: [.topLeft, .topRight]))
        }
    }

    private func toggle(_ id: String) {
        if selected.contains(id) {
            selected.remove(id)
        } else {
            selected.insert(id)
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

final class ConversationFilterModalViewController: UIHostingController<ConversationFilterModalView> {

    init(initialSelection: Set<String>, onApply: @escaping (Set<String>) -> Void, onReset: @escaping () -> Void) {
        var controllerRef: UIViewController?
        super.init(rootView: ConversationFilterModalView(
            initialSelection: initialSelection,
            onApply: onApply,
            onReset: onReset,
            onClose: { controllerRef?.dismiss(animated: true) }
        ))
        controllerRef = self
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        self.view.backgroundColor = .clear
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
