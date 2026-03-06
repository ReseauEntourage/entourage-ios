import UIKit

// MARK: - Fallback si setFontTitle(_:) n'existe pas dans ton projet
extension UILabel {
    @objc func setFontTitle(_ size: CGFloat) {
        // Remplace par ta font projet si dispo (ex: ApplicationTheme.getFontQuickSandBold(size:))
        self.font = UIFont.boldSystemFont(ofSize: size)
    }
}

// MARK: - ImageListViewController

final class ImageListViewController: UIViewController {
    var conversationId: Int = 0

    // Top bar
    private let topBar = UIView()
    private let backButton = UIImageView()
    private let titleLabel = UILabel()

    // Content
    private var collectionView: UICollectionView!
    private var images: [ConversationImage] = []

    // Empty state
    private let emptyStateView = UIView()
    private let emptyIcon = UIImageView()
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTopBar()
        setupCollection()
        setupEmptyState()
        fetchImages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let sidePadding: CGFloat = 16
            let columns: CGFloat = 3
            let inter = layout.minimumInteritemSpacing
            let width = view.bounds.width
            let itemWidth = floor((width - sidePadding * 2 - (columns - 1) * inter) / columns)
            if layout.itemSize.width != itemWidth {
                layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
                layout.invalidateLayout()
            }
        }
    }

    // MARK: - Setup TopBar (Back + Title)

    private func setupTopBar() {
        view.addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        var img = UIImage(named: "back_arrow")
        if img == nil {
            if #available(iOS 13.0, *) {
                img = UIImage(systemName: "chevron.left")
            }
        }

        backButton.image = img?.withRenderingMode(.alwaysTemplate)
        backButton.contentMode = .scaleAspectFit
        backButton.isUserInteractionEnabled = true
        backButton.accessibilityLabel = "Retour"
        backButton.accessibilityTraits = UIAccessibilityTraits.button
        if #available(iOS 13.0, *) {
            backButton.tintColor = .label
        } else {
            backButton.tintColor = .black
        }

        titleLabel.text = "Photos de la conversation"
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.setFontTitle(15)
        if #available(iOS 13.0, *) {
            titleLabel.textColor = .label
        } else {
            titleLabel.textColor = .black
        }

        topBar.addSubview(backButton)
        topBar.addSubview(titleLabel)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let verticalPadding: CGFloat = 8
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topBar.topAnchor, constant: verticalPadding),
            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: topBar.trailingAnchor, constant: -16),

            backButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -verticalPadding)
        ])

        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBack)))
    }

    // MARK: - Collection

    private func setupCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8

        let sidePadding: CGFloat = 16
        let columns: CGFloat = 3
        let width = view.bounds.width
        let itemWidth = floor((width - sidePadding*2 - (columns-1)*layout.minimumInteritemSpacing) / columns)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = UIEdgeInsets(top: 12, left: sidePadding, bottom: 12, right: sidePadding)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(ImageGridCell.self, forCellWithReuseIdentifier: ImageGridCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Empty State

    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(emptyIcon)
        emptyStateView.addSubview(emptyLabel)

        if #available(iOS 13.0, *) {
            emptyIcon.image = UIImage(systemName: "photo.on.rectangle.angled")
            emptyIcon.tintColor = .systemGray3
        } else {
            emptyIcon.image = UIImage(named: "placeholder") ?? UIImage()
            emptyIcon.tintColor = .lightGray
        }

        emptyLabel.text = "Aucune image partagée pour le moment"
        emptyLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        emptyLabel.textColor = .lightGray
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 2

        NSLayoutConstraint.activate([
            emptyIcon.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyIcon.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyIcon.widthAnchor.constraint(equalToConstant: 50),
            emptyIcon.heightAnchor.constraint(equalToConstant: 50),

            emptyLabel.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 10),
            emptyLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 8),
            emptyLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -8),
            emptyLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])

        emptyStateView.isHidden = true
    }

    private func updateEmptyState() {
        let isEmpty = images.isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    // MARK: - Actions

    @objc private func tapBack() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Data

    private func fetchImages() {
        MessagingService.getConversationImages(conversationId: conversationId) { [weak self] imgs, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.images = imgs ?? []
                self.collectionView.reloadData()
                self.updateEmptyState()
            }
        }
    }
}

// MARK: - UICollectionView

extension ImageListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageGridCell.reuseId, for: indexPath) as! ImageGridCell
        let item = images[indexPath.item]
        cell.spinner.startAnimating()

        if let urlStr = item.url {
            ImageCache.shared.load(urlStr) { [weak collectionView, weak cell] img in
                DispatchQueue.main.async {
                    guard let collectionView = collectionView,
                          let cell = cell,
                          let currentIndex = collectionView.indexPath(for: cell),
                          currentIndex == indexPath else { return }
                    cell.imageView.image = img
                    cell.spinner.stopAnimating()
                }
            }
        } else {
            cell.spinner.stopAnimating()
            cell.imageView.image = nil
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = images[indexPath.item].chatMessageId else { return }
        let vc = ImagePreviewController(conversationId: conversationId, chatMessageId: id)
        present(vc, animated: true)
    }
}
