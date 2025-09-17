import Foundation
import UIKit


protocol EnhancedOnboardingCollectionCellDelegate: AnyObject {
    func collectionCell(didSelect choice: OnboardingChoice)
}

class EnhancedOnboardingCollectionCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Variables
    var items: [OnboardingChoice] = []
    var selectedIds = Set<String>()
    weak var delegate: EnhancedOnboardingCollectionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        
        // Register the collection view cell
        collectionView.register(UINib(nibName: "InterestsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InterestsCollectionViewCell")
    }
    
    
    func setItems(_ items: [OnboardingChoice], selectedIds: Set<String>) {
        self.items = items
        self.selectedIds = selectedIds
        collectionView.reloadData()
    }
}

extension EnhancedOnboardingCollectionCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestsCollectionViewCell", for: indexPath) as? InterestsCollectionViewCell else {
            return UICollectionViewCell()
        }
        let choice = items[indexPath.row]
        let isSelected = selectedIds.contains(choice.id)
        cell.configure(choice: choice, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 7
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize / 2, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let choice = items[indexPath.row]
        delegate?.collectionCell(didSelect: choice)
    }
}
