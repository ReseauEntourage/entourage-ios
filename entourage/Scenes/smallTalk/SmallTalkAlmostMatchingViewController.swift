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
        //configureTest()
    }
    
    func configureTest() {
        // 🔹 Premier user request avec 1 seul user
        let soloUser = UserProfile(
            id: 101,
            display_name: "Alice Dupont",
            avatar_url: "https://picsum.photos/200/300",
            community_roles: []
        )

        let fakeRequest1 = UserSmallTalkRequestWithMatchData(
            userSmallTalkId: 1001,
            smallTalkId: nil,
            users: [soloUser],
            hasMatchedFormat: true,
            hasMatchedGender: true,
            hasMatchedLocality: false,
            hasMatchedInterest: true,
            hasMatchedProfile: false,
            unmatchCount: 2
        )

        // 🔹 Deuxième user request avec 5 users
        let usersGroup = [
            UserProfile(id: 201, display_name: "Bob Martin", avatar_url: "https://picsum.photos/200/300", community_roles: []),
            UserProfile(id: 202, display_name: "Chloé Bernard", avatar_url: "https://picsum.photos/200/300", community_roles: []),
            UserProfile(id: 203, display_name: "David Lefevre", avatar_url: "https://picsum.photos/200/300", community_roles: []),
            UserProfile(id: 204, display_name: "Emma Petit", avatar_url: "https://picsum.photos/200/300", community_roles: []),
        ]

        let fakeRequest2 = UserSmallTalkRequestWithMatchData(
            userSmallTalkId: 1002,
            smallTalkId: nil,
            users: usersGroup,
            hasMatchedFormat: false,
            hasMatchedGender: false,
            hasMatchedLocality: true,
            hasMatchedInterest: true,
            hasMatchedProfile: true,
            unmatchCount: 0
        )
        // Injection
        self.rows = [fakeRequest1, fakeRequest2]
        self.ui_tableview.reloadData()
    }

    private func setupUI() {
        ui_label_title.text = "small_talk_other_band_title".localized
        ui_label_title.setFontTitle(size: 24)
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

            SmallTalkService.forceMatch(id: data.userSmallTalkId) { response, error in
                DispatchQueue.main.async {
                    if let response = response, response.match == true, let smallTalkId = response.smalltalk_id {
                        self.openConversation(for: smallTalkId)
                    } else {
                        let message: String
                        if let err = error, err.code == "400" {
                            message = err.message ?? "Ce groupe n'est plus disponible."
                        } else {
                            message = "Impossible de rejoindre ce groupe."
                        }

                        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
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
