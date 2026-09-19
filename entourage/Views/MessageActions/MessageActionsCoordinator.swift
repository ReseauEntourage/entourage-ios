//
//  MessageActionsCoordinator.swift
//  entourage
//
//  Pilote les actions rapides d'un message (copier / modifier / supprimer /
//  traduire) pour le nouvel overlay unifié (MessageActionOverlay), en
//  réutilisant telle quelle la logique déjà validée de
//  ReportGroupChoosePageViewController (mêmes règles d'options, même alerte de
//  confirmation de suppression, mêmes appels serveur) plutôt que de la
//  dupliquer : une instance de ce contrôleur est instanciée en mémoire (jamais
//  affichée à l'écran) et pilotée directement via son
//  tableView(didSelectRowAt:), pour ne prendre aucun risque de faire diverger
//  ce comportement. Ce fichier reste par ailleurs inchangé et continue de
//  servir les autres écrans de signalement (publication entière, groupe,
//  action, event, conversation/utilisateur) hors périmètre de cet overlay.
//

import UIKit

/// Contexte minimal nécessaire pour piloter les actions rapides d'un message —
/// même forme que les propriétés historiquement passées à
/// ReportGroupMainViewController pour un message/commentaire.
struct MessageActionContext {
    var groupId: Int?
    var eventId: Int?
    var postId: Int?
    var chatMessageId: Int?
    var conversationId: Int?
    var userId: Int
    var textString: String?
    var allowsMessageEdit: Bool
    var messageStatus: String?
}

final class MessageActionsCoordinator: NSObject {

    private let chooseVc: ReportGroupChoosePageViewController
    private let onEdit: (Int, String?) -> Void
    private let onDeleted: () -> Void
    private let onTranslate: (Int) -> Void

    /// Garde une référence forte le temps qu'une action asynchrone (l'alerte de
    /// confirmation de suppression) aboutisse — `chooseVc.delegate` est faible.
    private static var retained: [MessageActionsCoordinator] = []

    init?(context: MessageActionContext,
          onEdit: @escaping (Int, String?) -> Void,
          onDeleted: @escaping () -> Void,
          onTranslate: @escaping (Int) -> Void) {
        guard let vc = UIStoryboard(name: StoryboardName.neighborhoodReport, bundle: nil)
            .instantiateViewController(withIdentifier: "reportChooseGroupVC") as? ReportGroupChoosePageViewController else {
            return nil
        }
        chooseVc = vc
        self.onEdit = onEdit
        self.onDeleted = onDeleted
        self.onTranslate = onTranslate
        super.init()

        vc.groupId = context.groupId
        vc.eventId = context.eventId
        vc.postId = context.postId
        vc.chatMessageId = context.chatMessageId
        vc.conversationId = context.conversationId
        vc.userId = context.userId
        vc.textString = context.textString
        vc.allowsMessageEdit = context.allowsMessageEdit
        vc.messageStatus = context.messageStatus
        vc.delegate = self
        vc.loadViewIfNeeded()
    }

    /// Options à afficher dans l'overlay, calculées par
    /// `ReportGroupChoosePageViewController.loadDTO()`.
    var options: [ReportCellType] { chooseVc.table_dto }
    var paramType: ParamSupressType { chooseVc.checkparameterType() }

    /// Déclenche l'action `type` en simulant la sélection de la ligne
    /// équivalente dans le chooser sous-jacent (jamais affiché à l'écran).
    func perform(_ type: ReportCellType) {
        guard let idx = chooseVc.table_dto.firstIndex(where: { areSame($0, type) }) else { return }
        MessageActionsCoordinator.retained.append(self)
        chooseVc.tableView(chooseVc.ui_tableview, didSelectRowAt: IndexPath(row: idx, section: 0))
    }

    private func areSame(_ a: ReportCellType, _ b: ReportCellType) -> Bool {
        switch (a, b) {
        case (.report, .report), (.suppress, .suppress), (.translate, .translate), (.copy, .copy), (.edit, .edit):
            return true
        default:
            return false
        }
    }

    private func finish() {
        MessageActionsCoordinator.retained.removeAll { $0 === self }
    }
}

// MARK: - ReportGroupPageDelegate
// (goBack/goNext/closeMain/chooseReport ne sont jamais atteints ici : le
// sous-flux "motif de signalement" est déclenché séparément, hors de ce
// coordinateur — voir `startAtReportReason` sur ReportGroupMainViewController.)
extension MessageActionsCoordinator: ReportGroupPageDelegate {
    func goBack() {}
    func goNext(tags: Tags) {}
    func closeMain() {}
    func chooseReport() {}

    func closeMainForDelete() {
        onDeleted()
        finish()
    }

    func translateItem(id: Int) {
        onTranslate(id)
        finish()
    }

    func copyItemText() {
        UIPasteboard.general.string = chooseVc.textString
        chooseVc.view.showToast(message: "copied_text".localized)
        finish()
    }

    func editItem(id: Int, textString: String?) {
        onEdit(id, textString)
        finish()
    }
}
