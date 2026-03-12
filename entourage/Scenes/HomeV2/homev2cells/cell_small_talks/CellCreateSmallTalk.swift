import UIKit
import SwiftUI

class CellCreateSmallTalk: UICollectionViewCell {
    
    static let identifier = "CellCreateSmallTalk"
    private var hostingController: UIHostingController<CellCreateSmallTalkView>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSwiftUIView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        // Initialisation de la vue SwiftUI avec le callback du bouton
        let swiftUIView = CellCreateSmallTalkView { [weak self] in
            self?.onBtnClick()
        }
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        
        contentView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        self.hostingController = hostingController
    }
    
    @objc private func onBtnClick() {
        guard let collectionView = self.parentCollectionView(),
              let indexPath = self.indexPathInCollectionView(),
              let delegate = collectionView.delegate else {
            return
        }

        delegate.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
}
