//
//  MessageActionOverlay.swift
//  entourage
//
//  Overlay flouté unifié (réactions + options), affiché directement sur le
//  message concerné — remplace l'ancien duo "barre de réaction inline" +
//  "bottomsheet de signalement" par un appui long ou un tap sur le bouton de
//  réaction : le fond est flouté, la bulle reste nette à sa place, la barre de
//  réactions apparaît au-dessus (jamais sur son propre message) et une carte
//  d'options juste en dessous (ou l'inverse si la place manque en bas d'écran).
//

import UIKit

final class MessageActionOverlay: NSObject {

    private static var current: MessageActionOverlay?

    private let window: UIWindow
    private let dimmingView = UIVisualEffectView(effect: nil)
    private let snapshot: UIView
    private var reactionBar: ReactionPickerBarView?
    private let optionsCard: UIView

    private let onReaction: (ReactionType) -> Void
    private let onOption: (ReportCellType) -> Void

    static func show(anchorView: UIView,
                      isMe: Bool,
                      reactionTypes: [ReactionType],
                      selectedReactionId: Int?,
                      options: [ReportCellType],
                      paramType: ParamSupressType,
                      onReaction: @escaping (ReactionType) -> Void,
                      onOption: @escaping (ReportCellType) -> Void) {
        guard let window = anchorView.window, !options.isEmpty else { return }
        current?.dismiss(animated: false)
        current = MessageActionOverlay(window: window,
                                        anchorView: anchorView,
                                        isMe: isMe,
                                        reactionTypes: reactionTypes,
                                        selectedReactionId: selectedReactionId,
                                        options: options,
                                        paramType: paramType,
                                        onReaction: onReaction,
                                        onOption: onOption)
    }

    private init(window: UIWindow,
                 anchorView: UIView,
                 isMe: Bool,
                 reactionTypes: [ReactionType],
                 selectedReactionId: Int?,
                 options: [ReportCellType],
                 paramType: ParamSupressType,
                 onReaction: @escaping (ReactionType) -> Void,
                 onOption: @escaping (ReportCellType) -> Void) {
        self.window = window
        self.onReaction = onReaction
        self.onOption = onOption

        let anchorFrame = anchorView.convert(anchorView.bounds, to: window)
        let snap = anchorView.snapshotView(afterScreenUpdates: false) ?? UIView(frame: anchorView.bounds)
        snap.frame = anchorFrame
        snap.isUserInteractionEnabled = false
        snapshot = snap

        optionsCard = MessageActionOverlay.buildOptionsCard(options: options, paramType: paramType)

        super.init()

        dimmingView.frame = window.bounds
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(dimmingView)
        window.addSubview(snapshot)

        if !isMe && !reactionTypes.isEmpty {
            let newBar = ReactionPickerBarView()
            newBar.translatesAutoresizingMaskIntoConstraints = true
            newBar.configure(types: reactionTypes, selectedId: selectedReactionId) { [weak self] type in
                self?.onReaction(type)
                self?.dismiss(animated: true)
            }
            window.addSubview(newBar)
            reactionBar = newBar
        }

        optionsCard.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(optionsCard)

        layout(anchorFrame: anchorFrame)
        wireOptionRows()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        dimmingView.addGestureRecognizer(tap)

        animateIn()
    }

    // MARK: - Present / dismiss

    private func animateIn() {
        dimmingView.alpha = 0
        snapshot.alpha = 0
        snapshot.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        reactionBar?.alpha = 0
        optionsCard.alpha = 0
        optionsCard.transform = CGAffineTransform(translationX: 0, y: 8)

        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseOut, animations: { [self] in
            dimmingView.effect = UIBlurEffect(style: .regular)
            dimmingView.alpha = 1
            snapshot.alpha = 1
            snapshot.transform = .identity
            reactionBar?.alpha = 1
            optionsCard.alpha = 1
            optionsCard.transform = .identity
        })
    }

    @objc private func handleBackgroundTap() {
        dismiss(animated: true)
    }

    @objc private func handleOptionRowTap(_ sender: UIButton) {
        guard let type = MessageActionOverlay.type(forTag: sender.tag) else { return }
        onOption(type)
        dismiss(animated: true)
    }

    private func dismiss(animated: Bool) {
        if MessageActionOverlay.current === self {
            MessageActionOverlay.current = nil
        }
        let dimmingView = self.dimmingView
        let snapshot = self.snapshot
        let reactionBar = self.reactionBar
        let optionsCard = self.optionsCard
        let cleanup = {
            dimmingView.removeFromSuperview()
            snapshot.removeFromSuperview()
            reactionBar?.removeFromSuperview()
            optionsCard.removeFromSuperview()
        }
        guard animated else { cleanup(); return }
        UIView.animate(withDuration: 0.18, animations: {
            dimmingView.alpha = 0
            snapshot.alpha = 0
            reactionBar?.alpha = 0
            optionsCard.alpha = 0
        }, completion: { _ in cleanup() })
    }

    // MARK: - Layout

    private func layout(anchorFrame: CGRect) {
        let screenBounds = window.bounds
        let margin: CGFloat = 16
        let spacing: CGFloat = 10
        let safeTop = window.safeAreaInsets.top + margin
        let safeBottom = screenBounds.height - window.safeAreaInsets.bottom - margin

        let cardSize = optionsCard.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let barSize = reactionBar?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

        func clampedX(width: CGFloat) -> CGFloat {
            let x = anchorFrame.midX - width / 2
            return min(max(x, margin), max(margin, screenBounds.width - margin - width))
        }

        let spaceBelow = safeBottom - anchorFrame.maxY

        if spaceBelow >= spacing + cardSize.height {
            // Cas courant : réactions au-dessus de la bulle, options en dessous.
            if let bar = reactionBar {
                bar.frame = CGRect(x: clampedX(width: barSize.width),
                                    y: max(safeTop, anchorFrame.minY - spacing - barSize.height),
                                    width: barSize.width, height: barSize.height)
            }
            optionsCard.frame = CGRect(x: clampedX(width: cardSize.width),
                                        y: anchorFrame.maxY + spacing,
                                        width: cardSize.width, height: cardSize.height)
        } else {
            // Pas assez de place en bas (message proche du bas de l'écran) :
            // on empile réactions + options au-dessus de la bulle.
            var y = anchorFrame.minY - spacing - cardSize.height
            optionsCard.frame = CGRect(x: clampedX(width: cardSize.width), y: max(safeTop, y),
                                        width: cardSize.width, height: cardSize.height)
            if let bar = reactionBar {
                y -= (spacing + barSize.height)
                bar.frame = CGRect(x: clampedX(width: barSize.width), y: max(safeTop, y),
                                    width: barSize.width, height: barSize.height)
            }
        }
    }

    // MARK: - Options card

    private static func buildOptionsCard(options: [ReportCellType], paramType: ParamSupressType) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        card.layer.masksToBounds = true

        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor)
        ])

        for (index, type) in options.enumerated() {
            let row = makeRow(for: type, paramType: paramType)
            stack.addArrangedSubview(row)
            row.heightAnchor.constraint(equalToConstant: 50).isActive = true

            if index < options.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .appGrisReaction
                separator.translatesAutoresizingMaskIntoConstraints = false
                card.addSubview(separator)
                NSLayoutConstraint.activate([
                    separator.heightAnchor.constraint(equalToConstant: 0.5),
                    separator.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                    separator.trailingAnchor.constraint(equalTo: card.trailingAnchor),
                    separator.bottomAnchor.constraint(equalTo: row.bottomAnchor)
                ])
            }
        }

        card.widthAnchor.constraint(equalToConstant: 230).isActive = true
        return card
    }

    private static func makeRow(for type: ReportCellType, paramType: ParamSupressType) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag(for: type)
        var color: UIColor = .black
        if case .edit = type { color = .appOrange }

        // Icône et libellé posés manuellement (taille fixe) plutôt que via
        // setImage/setTitle : les assets ic_report/ic_supress/... ont des tailles
        // natives variables, imageEdgeInsets seul ne suffit pas à les contraindre
        // et provoque un chevauchement avec le libellé.
        let iconView = UIImageView(image: icon(for: type))
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = color
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isUserInteractionEnabled = false

        let label = UILabel()
        label.text = title(for: type, paramType: paramType)
        label.textColor = color
        label.font = UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false

        button.addSubview(iconView)
        button.addSubview(label)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        return button
    }

    private func wireOptionRows() {
        guard let stack = optionsCard.subviews.first(where: { $0 is UIStackView }) as? UIStackView else { return }
        for case let button as UIButton in stack.arrangedSubviews {
            button.addTarget(self, action: #selector(handleOptionRowTap(_:)), for: .touchUpInside)
        }
    }

    private static func tag(for type: ReportCellType) -> Int {
        switch type {
        case .copy: return 0
        case .edit: return 1
        case .suppress: return 2
        case .translate: return 3
        case .report: return 4
        }
    }

    private static func type(forTag tag: Int) -> ReportCellType? {
        switch tag {
        case 0: return .copy
        case 1: return .edit
        case 2: return .suppress
        case 3: return .translate
        case 4: return .report
        default: return nil
        }
    }

    /// Mêmes assets que `ReportChooseViewCell.populate` (fichier non modifié,
    /// utilisé par d'autres écrans de signalement hors périmètre).
    private static func icon(for type: ReportCellType) -> UIImage? {
        switch type {
        case .report: return UIImage(named: "ic_report")
        case .suppress: return UIImage(named: "ic_supress")
        case .translate: return UIImage(named: "ic_translation")
        case .copy: return UIImage(named: "ic_copy")
        case .edit: return UIImage(named: "ic_profil_full_pen")?.withRenderingMode(.alwaysTemplate)
        }
    }

    /// Mêmes clés localisées que `ReportChooseViewCell.populate`.
    private static func title(for type: ReportCellType, paramType: ParamSupressType) -> String {
        switch type {
        case .report:
            return "report_post_cell_title".localized
        case .translate:
            return "report_modal_title_translate".localized
        case .copy:
            return "copy_the_text".localized
        case .edit:
            return "modify".localized
        case .suppress:
            switch paramType {
            case .message: return "suppress_message_cell_title".localized
            case .commment: return "suppress_comment_cell_title".localized
            case .publication, .action: return "suppress_post_cell_title".localized
            }
        }
    }
}
