final class SmallTalkAlmostMatchingViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_subtitle: UILabel!
    @IBOutlet weak var ui_btn_leave: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!

    // MARK: - Données
    private var rows: [UserSmallTalkRequestWithMatchData] = []

    // Champs configurables
    private var matchingGroup: String = "one"
    private var matchingGender: Bool = false
    private var matchingLocality: Bool = false
    private var userRequestId: String?

    // MARK: - Public (appelé avant .present)
    func configure(with requestId: String, group: String, gender: Bool, locality: Bool) {
        self.userRequestId = requestId
        self.matchingGroup = group
        self.matchingGender = gender
        self.matchingLocality = locality
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTable()
        fetchAlmostMatches()
    }

    private func setupUI() {
        ui_label_title.text = "small_talk_other_band_title".localized
        ui_label_title.setFontTitle(size: 20)
        ui_label_subtitle.setFontBody(size: 15)
        ui_label_subtitle.text = NSLocalizedString("small_talk_other_band_subtitle".localized, comment: "")
        configureOrangeButton(ui_btn_leave, withTitle: NSLocalizedString("small_talk_other_band_wait".localized, comment: ""))
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

    private func configureTable() {
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.separatorStyle = .none
        ui_tableview.backgroundColor = .clear
        ui_tableview.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        ui_tableview.register(UINib(nibName: "CellAlmostMatching", bundle: nil), forCellReuseIdentifier: "CellAlmostMatching")
    }

    private func fetchAlmostMatches() {
        SmallTalkService.listAlmostMatches { [weak self] matches, _ in
            guard let self = self else { return }

            let safeMatches = matches ?? []

            if safeMatches.isEmpty {
                DispatchQueue.main.async {
                    self.redirectToNoMatch()
                }
            } else {
                self.rows = safeMatches
                DispatchQueue.main.async {
                    self.ui_tableview.reloadData()
                }
            }
        }
    }

    private func redirectToNoMatch() {
        let sb = UIStoryboard(name: "SmallTalk", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "SmallTalkNoBandFoundViewController") as? SmallTalkNoBandFoundViewController {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }

    @objc private func handleLeaveTapped() {
        self.dismiss(animated: true) {
            AppState.navigateToMainApp()
        }
    }

    private func openConversation(for conversationId: Int) {
        let storyboard = UIStoryboard(name: StoryboardName.messages, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
            vc.setupFromOtherVC(conversationId: conversationId, title: nil, isOneToOne: true)
            AppState.getTopViewController()?.present(vc, animated: true)
        }
    }
}

// MARK: - TableView

extension SmallTalkAlmostMatchingViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = rows[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellAlmostMatching", for: indexPath) as? CellAlmostMatching else {
            return UITableViewCell()
        }

        cell.configure(with: data)

        cell.onJoinTapped = { [weak self] in
            guard let self = self else { return }
            SmallTalkService.forceMatch(id: data.userSmallTalkId) { response, _ in
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.cornerRadius = 20
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
    }
}
