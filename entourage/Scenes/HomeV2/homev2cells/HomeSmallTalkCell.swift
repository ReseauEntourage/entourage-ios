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

        ui_collection_view.decelerationRate = .fast
        ui_collection_view.showsHorizontalScrollIndicator = false

        // Register cells
        ui_collection_view.register(UINib(nibName: "CellCreateSmallTalk", bundle: nil), forCellWithReuseIdentifier: "CellCreateSmallTalk")
        ui_collection_view.register(UINib(nibName: "CellWaitingSmallTalk", bundle: nil), forCellWithReuseIdentifier: "CellWaitingSmallTalk")
        ui_collection_view.register(UINib(nibName: "CellDiscussionSmallTalk", bundle: nil), forCellWithReuseIdentifier: "CellDiscussionSmallTalk")

        if let layout = ui_collection_view.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
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
            
            return collectionView.dequeueReusableCell(withReuseIdentifier: "CellCreateSmallTalk", for: indexPath)
        case .waiting:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "CellWaitingSmallTalk", for: indexPath)
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
        let width = collectionView.bounds.width * 0.90
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = data[indexPath.item]

        switch item {
        case .talking(let userRequest):
            let sb = UIStoryboard(name: StoryboardName.messages, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController,
               let smalltalkId = userRequest.smalltalk_id {
                
                let smalltalkIdString = String(smalltalkId)
                vc.setupFromOtherVC(conversationId: smalltalkId, title: "Bonnes ondes", isOneToOne: true, conversation: nil)
                vc.isSmallTalkMode = true
                vc.smallTalkId = smalltalkIdString
                parentViewController?.present(vc, animated: true)
            }

        case .create:
            let storyboard = UIStoryboard(name: "SmallTalk", bundle: nil)
            guard let vc = storyboard.instantiateInitialViewController() else { return }
            vc.modalPresentationStyle = .fullScreen
            parentViewController?.present(vc, animated: true)
            
            
//        case .create: //Testing the almostMatching
//            let storyboard = UIStoryboard(name: "SmallTalk", bundle: nil)
//
//            guard let vc = storyboard.instantiateViewController(withIdentifier: "SmallTalkAlmostMatchingViewController") as? SmallTalkAlmostMatchingViewController else { return }
//
//            // 👉 Configuration de test ici (tu peux garder les vraies valeurs si tu les as)
//            vc.configure(
//                with: "fake_request_id",
//                group: "one",
//                gender: true,
//                locality: true
//            )
//
//            // 👉 Ajoute configureTest si tu veux injecter des données factices :
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                vc.configureTest()
//            }
//            vc.modalPresentationStyle = .fullScreen
//            parentViewController?.present(vc, animated: true)

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
                        guard let self = self else { return }
                        if success {
                            self.data.removeAll(where: {
                                if case .waiting = $0 { return true }
                                return false
                            })
                            self.ui_collection_view.reloadData()
                        } else {
                            let errorAlert = UIAlertController(
                                title: "Erreur",
                                message: "Impossible de supprimer la demande.",
                                preferredStyle: .alert
                            )
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.parentViewController?.present(errorAlert, animated: true)
                        }
                    }
                }
            }))

            parentViewController?.present(alert, animated: true)
        }
    }
}
