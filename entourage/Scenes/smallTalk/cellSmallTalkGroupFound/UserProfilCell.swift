import UIKit

class UserProfileCell: UICollectionViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var interestsCollectionView: UICollectionView!

    private var interests: [String] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 30)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8

        interestsCollectionView.collectionViewLayout = layout
        interestsCollectionView.delegate = self
        interestsCollectionView.dataSource = self
        interestsCollectionView.isScrollEnabled = false
        interestsCollectionView.backgroundColor = .clear

        // ✅ Correction ici : nom du reuseIdentifier
        interestsCollectionView.register(SmallTalkInterestCell.self, forCellWithReuseIdentifier: "SmallTalkInterestCell")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.image = nil
        interests = []
        interestsCollectionView.reloadData()
    }

    func configure(with user: User) {
        nameLabel.text = user.displayName

        if let urlString = user.avatarURL, let url = URL(string: urlString) {
            loadImage(from: url, into: avatar)
        } else {
            avatar.image = UIImage(named: "place_holder_large")
        }

        self.interests = user.interests ?? []
        interestsCollectionView.reloadData()
    }

    private func loadImage(from url: URL, into imageView: UIImageView) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
}

// MARK: - CollectionView Delegate/DataSource
extension UserProfileCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // ✅ Correction ici aussi
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmallTalkInterestCell", for: indexPath) as? SmallTalkInterestCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: interests[indexPath.item])
        return cell
    }
}


