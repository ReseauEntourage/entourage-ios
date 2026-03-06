//
//  EventParamsCGUViewController.swift
//  entourage
//
//  Created by Jerome on 25/07/2022.
//  Updated by ChatGPT on 14/10/2025
//

import UIKit

// MARK: - Model
struct CharterItem {
    let title: String
    let description: String
}

final class EventParamsCGUViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var ui_view_top: MJNavBackView!
    @IBOutlet private weak var ui_tableview: UITableView!

    // MARK: - Data
    private enum Section: Int, CaseIterable {
        case positive
        case negative
    }

    private var positiveItems: [CharterItem] = []
    private var negativeItems: [CharterItem] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Header (back + titre)
        ui_view_top.populateView(
            title: "event_charter_nav_title".localized, // "Charte Entourage"
            titleFont: ApplicationTheme.getFontQuickSandBold(size: 15),
            titleColor: .black,
            delegate: self,
            isClose: false
        )

        setupTableView()
        buildContent()

        AnalyticsLoggerManager.logEvent(name: View_GroupOption_Rules)
    }

    // MARK: - Setup
    private func setupTableView() {
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.separatorStyle = .none
        ui_tableview.tableFooterView = UIView()
        ui_tableview.estimatedRowHeight = 80
        ui_tableview.rowHeight = UITableView.automaticDimension
        if #available(iOS 15.0, *) { ui_tableview.sectionHeaderTopPadding = 0 }

        // ✅ On affiche les titres de section comme des rows -> on enregistre la cellule 100% code.
        ui_tableview.register(EventRuleSectionTitle.self, forCellReuseIdentifier: EventRuleSectionTitle.reuseId)

        // Si NeighborhoodCguCell est en XIB (et pas prototype storyboard), on l’enregistre “safe”.
        if Bundle.main.path(forResource: "NeighborhoodCguCell", ofType: "nib") != nil {
            let cguNib = UINib(nibName: "NeighborhoodCguCell", bundle: nil)
            ui_tableview.register(cguNib, forCellReuseIdentifier: "cell_cgu")
        }
    }

    // MARK: - Content
    private func buildContent() {
        // Section 1 : Nous venons pour…
        positiveItems = [
            CharterItem(
                title: "event_charter_positive_1_title".localized,
                description: "event_charter_positive_1_desc".localized
            ),
            CharterItem(
                title: "event_charter_positive_2_title".localized,
                description: "event_charter_positive_2_desc".localized
            ),
            CharterItem(
                title: "event_charter_positive_3_title".localized,
                description: "event_charter_positive_3_desc".localized
            ),
            CharterItem(
                title: "event_charter_positive_4_title".localized,
                description: "event_charter_positive_4_desc".localized
            )
        ]

        // Section 2 : Ce qu’on ne peut pas accepter
        negativeItems = [
            CharterItem(
                title: "event_charter_negative_1_title".localized,
                description: "event_charter_negative_1_desc".localized
            ),
            CharterItem(
                title: "event_charter_negative_2_title".localized,
                description: "event_charter_negative_2_desc".localized
            ),
            CharterItem(
                title: "event_charter_negative_3_title".localized,
                description: "event_charter_negative_3_desc".localized
            ),
            CharterItem(
                title: "event_charter_negative_4_title".localized,
                description: "event_charter_negative_4_desc".localized
            )
        ]
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate
extension EventParamsCGUViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    /// +1 ligne par section : la ligne 0 sert de "titre de section" (EventRuleSectionTitle).
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .positive: return positiveItems.count + 1
        case .negative: return negativeItems.count + 1
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Ligne 0 : cellule-titre de section (remplace le header sticky)
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: EventRuleSectionTitle.reuseId,
                for: indexPath
            ) as! EventRuleSectionTitle

            switch Section(rawValue: indexPath.section)! {
            case .positive:
                cell.configure("event_charter_section_positive_title".localized)
            case .negative:
                cell.configure("event_charter_section_negative_title".localized)
            }
            return cell
        }

        // Lignes suivantes : contenu (NeighborhoodCguCell)
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell_cgu",
            for: indexPath
        ) as? NeighborhoodCguCell else {
            // Fallback neutre si la cellule n'est pas correctement liée
            let fallback = UITableViewCell(style: .subtitle, reuseIdentifier: "fallback_cgu")
            fallback.selectionStyle = .none
            return fallback
        }

        switch Section(rawValue: indexPath.section)! {
        case .positive:
            let item = positiveItems[indexPath.row - 1]
            cell.populateCell(title: item.title, description: item.description)
        case .negative:
            let item = negativeItems[indexPath.row - 1]
            cell.populateCell(title: item.title, description: item.description)
        }
        return cell
    }

    // ❌ Pas de headers de section "système"
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { nil }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { .leastNormalMagnitude }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat { .leastNormalMagnitude }

    // Petit espace entre sections
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 12 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { UIView() }
}

// MARK: - MJNavBackViewDelegate
extension EventParamsCGUViewController: MJNavBackViewDelegate {
    func goBack() {
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    func didTapEvent() {
        // Nothing yet
    }
}
