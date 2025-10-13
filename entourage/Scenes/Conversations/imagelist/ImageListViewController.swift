import UIKit

final class ImageListViewController: UIViewController {
    var conversationId: Int = 0

    private let backButton = UIImageView()
    private var collectionView: UICollectionView!
    private var images: [ConversationImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupBackButton()
        setupCollection()
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

    // MARK: - Setup

    private func setupBackButton() {
        // 1) Image: asset prioritaire
        var img = UIImage(named: "back_arrow")

        // 2) Si pas d’asset, tenter SF Symbol (iOS 13+), sinon on reste nil
        if img == nil {
            if #available(iOS 13.0, *) {
                img = UIImage(named: "back_arrow")
            }
        }

        backButton.image = img?.withRenderingMode(.alwaysTemplate)
        backButton.contentMode = .scaleAspectFit
        backButton.isUserInteractionEnabled = true
        backButton.accessibilityLabel = "Retour"
        backButton.accessibilityTraits = UIAccessibilityTraits.button

        // Couleur compatible < iOS 13
        if #available(iOS 13.0, *) {
            backButton.tintColor = .label
        } else {
            backButton.tintColor = .black
        }

        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28)
        ])

        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBack)))
    }

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
            collectionView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // S’assurer que le bouton est au-dessus
        view.bringSubviewToFront(backButton)
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
