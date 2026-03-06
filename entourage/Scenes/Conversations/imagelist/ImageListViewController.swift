import UIKit

// MARK: - Fallback si setFontTitle(_:) n'existe pas dans ton projet

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

    // Pagination state
    private let perPage: Int = 40
    private var currentPage: Int = 1
    private var isLoading: Bool = false
    private var hasMore: Bool = true

    // Footer loading (spinner en bas)
    private let loadingMoreContainer = UIView()
    private let loadingMoreSpinner = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTopBar()
        setupCollection()
        setupEmptyState()
        setupLoadingMore()
        fetchFirstPage()
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
        titleLabel.setFontTitle(size: 15)
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

    // MARK: - Footer "loading more"

    private func setupLoadingMore() {
        view.addSubview(loadingMoreContainer)
        loadingMoreContainer.translatesAutoresizingMaskIntoConstraints = false
        loadingMoreContainer.isHidden = true

        loadingMoreContainer.addSubview(loadingMoreSpinner)
        loadingMoreSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingMoreSpinner.hidesWhenStopped = true

        NSLayoutConstraint.activate([
            loadingMoreContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingMoreContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingMoreContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            loadingMoreContainer.heightAnchor.constraint(equalToConstant: 44),

            loadingMoreSpinner.centerXAnchor.constraint(equalTo: loadingMoreContainer.centerXAnchor),
            loadingMoreSpinner.centerYAnchor.constraint(equalTo: loadingMoreContainer.centerYAnchor)
        ])
    }

    private func setLoadingMore(_ loading: Bool) {
        loadingMoreContainer.isHidden = !loading
        if loading {
            loadingMoreSpinner.startAnimating()
            // petit inset bas pour ne pas masquer la dernière rangée
            collectionView.contentInset.bottom = 44
        } else {
            loadingMoreSpinner.stopAnimating()
            collectionView.contentInset.bottom = 0
        }
    }

    // MARK: - Actions

    @objc private func tapBack() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Data & Pagination

    private func fetchFirstPage() {
        currentPage = 1
        hasMore = true
        isLoading = true
        setLoadingMore(true)
        MessagingService.getConversationImages(
            conversationId: conversationId,
            page: currentPage,
            per: perPage
        ) { [weak self] imgs, nextPage, _ in
            guard let self = self else { return }
            self.isLoading = false
            self.setLoadingMore(false)
            self.images = imgs ?? []
            self.collectionView.reloadData()
            self.updateEmptyState()
            if let np = nextPage {
                self.currentPage = np
                self.hasMore = true
            } else {
                self.hasMore = false
            }
        }
    }

    private func loadMoreIfNeeded(for indexPath: IndexPath) {
        // Déclenchement quand on approche de la fin (ex: derniers 6 items)
        let threshold = 6
        guard hasMore, !isLoading, indexPath.item >= images.count - threshold else { return }

        isLoading = true
        setLoadingMore(true)
        MessagingService.getConversationImages(
            conversationId: conversationId,
            page: currentPage,
            per: perPage
        ) { [weak self] imgs, nextPage, _ in
            guard let self = self else { return }
            self.isLoading = false
            self.setLoadingMore(false)

            let newItems = imgs ?? []
            if newItems.isEmpty {
                self.hasMore = false
                return
            }

            let start = self.images.count
            self.images.append(contentsOf: newItems)

            // Insertions performantes
            let indexPaths = (start..<(start + newItems.count)).map { IndexPath(item: $0, section: 0) }
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: indexPaths)
            }, completion: nil)

            if let np = nextPage {
                self.currentPage = np
                self.hasMore = true
            } else {
                self.hasMore = false
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

    // Détection d’approche du bas de liste
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loadMoreIfNeeded(for: indexPath)
    }
}
