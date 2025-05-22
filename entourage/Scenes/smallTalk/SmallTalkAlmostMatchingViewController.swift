//
//  SmallTalkAlmostMatchingViewController.swift
//  entourage
//
//  Created by Clement entourage on 21/05/2025.
//

import UIKit

final class SmallTalkAlmostMatchingViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_subtitle: UILabel!
    @IBOutlet weak var ui_btn_leave: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!

    // MARK: - Config
    var matchingLocality: Bool = false
    var matchingGender: Bool = true
    var matchingGroup: String = "one"

    // MARK: - Rows
    private enum Row {
        case almostMatching(UserSmallTalkRequest)
    }

    private var rows: [Row] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTable()
        fetchAlmostMatches()
    }

    // MARK: - UI Setup
    private func setupUI() {
        ui_label_title.text = NSLocalizedString("small_talk_other_band_title", comment: "")
        ui_label_subtitle.text = NSLocalizedString("small_talk_other_band_subtitle", comment: "")
        configureOrangeButton(ui_btn_leave, withTitle: NSLocalizedString("small_talk_other_band_wait", comment: ""))
        ui_btn_leave.addTarget(self, action: #selector(handleLeaveTapped), for: .touchUpInside)
    }

    private func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }

    // MARK: - Table
    private func configureTable() {
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.separatorStyle = .none
        ui_tableview.register(UINib(nibName: "CellAlmostMatching", bundle: nil), forCellReuseIdentifier: "CellAlmostMatching")
    }
    
    func configure(
        with requestId: String,
        group: String,
        gender: Bool,
        locality: Bool
    ) {
        self.matchingGroup = group
        self.matchingGender = gender
        self.matchingLocality = locality
    }


    // MARK: - Load Data
    private func fetchAlmostMatches() {
        SmallTalkService.listUserSmallTalkRequests { [weak self] requests, _ in
            guard let self = self else { return }

            let matches = (requests ?? []).filter { $0.smalltalk_id != nil }
            if matches.isEmpty {
                self.redirectToNoMatch()
                return
            }

            self.rows = matches.map { .almostMatching($0) }
            DispatchQueue.main.async {
                self.ui_tableview.reloadData()
            }
        }
    }

    // MARK: - Navigation
    private func redirectToNoMatch() {
//        let vc = SmallTalkNoBandFoundViewController() // à créer
//        navigationController?.setViewControllers([vc], animated: true)
    }

    private func openConversation(for conversationId: Int) {
        let storyboard = UIStoryboard(name: StoryboardName.messages, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
            vc.setupFromOtherVC(conversationId: conversationId, title: nil, isOneToOne: true)
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }


    // MARK: - Actions
    @objc private func handleLeaveTapped() {
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension SmallTalkAlmostMatchingViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch rows[indexPath.row] {
        case .almostMatching(let request):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellAlmostMatching", for: indexPath) as? CellAlmostMatching else {
                return UITableViewCell()
            }

            cell.configure(
                with: request,
                matchingLocality: matchingLocality,
                matchingGender: matchingGender,
                matchingGroup: matchingGroup
            )

            cell.onJoinTapped = { [weak self] in
                guard let self = self else { return }
                guard let uuid = request.uuid_v2 else { return }

                SmallTalkService.forceMatch(id: uuid) { response, error in
                    guard let smallTalkId = response?.smalltalk_id, response?.match == true else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Erreur", message: "Impossible de rejoindre ce groupe.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        self.openConversation(for: smallTalkId)
                    }
                }
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
