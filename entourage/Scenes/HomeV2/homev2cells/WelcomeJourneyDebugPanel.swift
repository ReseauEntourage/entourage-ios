#if DEBUG
import SwiftUI
import UIKit

/// Données du tableau temporaire du parcours de bienvenue (build debug uniquement).
/// Mis à jour à chaque refresh du `home/summary` et à chaque tap sur une étape / "Passer".
final class WelcomeJourneyDebugModel: ObservableObject {
    static let shared = WelcomeJourneyDebugModel()

    struct Row: Identifiable {
        let type: WelcomeJourneyStepType
        let state: WelcomeJourneyStepState
        let hasCompletedEvent: Bool
        let hasSkippedEvent: Bool
        var id: String { type.identifier }
    }

    @Published private(set) var rows: [Row] = []
    @Published private(set) var events: [String] = []
    @Published private(set) var hiddenEntirely = false
    @Published private(set) var logs: [String] = []

    private init() {}

    func refresh(events: [String], hiddenEntirely: Bool) {
        self.events = events
        self.hiddenEntirely = hiddenEntirely
        self.rows = WelcomeJourneyStepType.allCases.map { type in
            Row(type: type,
                state: WelcomeJourneyViewModel.state(of: type, events: events),
                hasCompletedEvent: events.contains(type.completedEvent),
                hasSkippedEvent: events.contains(type.skippedEvent))
        }
    }

    func log(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        logs.append("\(formatter.string(from: Date()))  \(message)")
        if logs.count > 8 { logs.removeFirst(logs.count - 8) }
    }
}

struct WelcomeJourneyDebugView: View {
    @ObservedObject var model: WelcomeJourneyDebugModel
    let onClose: () -> Void

    private func label(_ state: WelcomeJourneyStepState) -> String {
        switch state {
        case .completed: return "✅ terminée"
        case .skipped: return "⏭ passée"
        case .active: return "⏳ à faire"
        }
    }

    private func mark(_ value: Bool) -> String { value ? "●" : "○" }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("🧪 Parcours de bienvenue (debug)")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                }
                .accessibilityIdentifier("welcome_debug_close")
            }

            if model.hiddenEntirely {
                Text("Parcours masqué (tout était déjà résolu au lancement)")
                    .font(.system(size: 11)).foregroundColor(.red)
            }

            ForEach(model.rows) { row in
                HStack(spacing: 6) {
                    Text(row.type.identifier)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .frame(width: 78, alignment: .leading)
                    Text(label(row.state))
                        .font(.system(size: 12))
                        .frame(width: 92, alignment: .leading)
                    Text("done \(mark(row.hasCompletedEvent))  skip \(mark(row.hasSkippedEvent))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("welcome_debug_row_\(row.type.identifier)")
                .accessibilityValue(label(row.state))
            }

            Divider()

            ForEach(Array(model.logs.enumerated()), id: \.offset) { entry in
                Text(entry.element)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.96))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 2)
    }
}

/// Affiche / masque le tableau devant l'écran d'accueil (long click sur le logo).
enum WelcomeJourneyDebugPanel {
    private static let tag = 987_654

    static func toggle(in host: UIViewController) {
        if let existing = host.view.viewWithTag(tag) {
            existing.removeFromSuperview()
            return
        }

        let panel = UIHostingController(rootView: WelcomeJourneyDebugView(model: .shared, onClose: { [weak host] in
            host?.view.viewWithTag(tag)?.removeFromSuperview()
        }))
        panel.view.tag = tag
        panel.view.backgroundColor = .clear
        panel.view.translatesAutoresizingMaskIntoConstraints = false
        host.addChild(panel)
        host.view.addSubview(panel.view)
        panel.didMove(toParent: host)

        NSLayoutConstraint.activate([
            panel.view.leadingAnchor.constraint(equalTo: host.view.leadingAnchor, constant: 8),
            panel.view.trailingAnchor.constraint(equalTo: host.view.trailingAnchor, constant: -8),
            panel.view.bottomAnchor.constraint(equalTo: host.view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
}
#endif
