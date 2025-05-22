import UIKit

enum CollectionDTO {
    case talking(UserSmallTalkRequest)
    case waiting
    case create
}

class HomeSmallTalkCell: UITableViewCell {
    weak var parentViewController: UIViewController?

    class var identifier: String {
        return String(describing: self)
    }
    
    // MARK: - Outlets
    @IBOutlet weak var ui_collection_view: UICollectionView!

    // MARK: - Properties
    var data: [CollectionDTO] = [] {
        didSet {
            ui_collection_view.reloadData()
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }

    // MARK: - Setup
    private func setupCollectionView() {
        ui_collection_view.delegate = self
        ui_collection_view.dataSource = self

        // Register all 3 cells
        ui_collection_view.register(UINib(nibName: "CellCreateSmallTalk", bundle: nil), forCellWithReuseIdentifier: "CellCreateSmallTalk")
        ui_collection_view.register(UINib(nibName: "CellWaitingSmallTalk", bundle: nil), forCellWithReuseIdentifier: "CellWaitingSmallTalk")
        ui_collection_view.register(UINib(nibName: "CellDiscussionSmallTalk", bundle: nil), forCellWithReuseIdentifier: "CellDiscussionSmallTalk")

        // Layout: full width
        if let layout = ui_collection_view.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 16
            layout.minimumInteritemSpacing = 0
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeSmallTalkCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = data[indexPath.item]
        switch item {
        case .create:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellCreateSmallTalk", for: indexPath)
            return cell
        case .waiting:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellWaitingSmallTalk", for: indexPath)
            return cell
        case .talking(let request):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellDiscussionSmallTalk", for: indexPath) as! CellDiscussionSmallTalk
            cell.configure(with: request)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeSmallTalkCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // La cell prend toute la largeur de la tableViewCell
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let item = data[indexPath.item]

            switch item {
            case .create:
                // 👉 Charger le storyboard
                let storyboard = UIStoryboard(name: "SmallTalk", bundle: nil)
                guard let vc = storyboard.instantiateInitialViewController() else {
                    return
                }

                // 👉 Toujours présenter en plein écran, pas de push
                vc.modalPresentationStyle = .fullScreen
                parentViewController?.present(vc, animated: true)
                
            case .waiting:
                let alert = UIAlertController(
                    title: "Annuler la demande ?",
                    message: "Souhaitez-vous supprimer votre demande SmallTalk en attente ?",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))

                alert.addAction(UIAlertAction(title: "Supprimer", style: .destructive, handler: { [weak self] _ in
                    SmallTalkService.deleteRequest { success in
                        DispatchQueue.main.async {
                            if success {
                                // Optionnel : mettre à jour l’UI immédiatement
                                self?.data.removeAll(where: {
                                    if case .waiting = $0 { return true }
                                    return false
                                })
                                self?.ui_collection_view.reloadData()
                            } else {
                                let errorAlert = UIAlertController(
                                    title: "Erreur",
                                    message: "Impossible de supprimer la demande.",
                                    preferredStyle: .alert
                                )
                                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                                self?.parentViewController?.present(errorAlert, animated: true)
                            }
                        }
                    }
                }))

                parentViewController?.present(alert, animated: true)
                return

            default:
                break // Les autres types ne déclenchent rien ici
            }
        }
}
