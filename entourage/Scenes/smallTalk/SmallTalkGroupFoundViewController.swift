//
//  SmallTalkGroupFoundViewController.swift
//  entourage
//
//  Created by Clement entourage on 20/05/2025.
//

import Foundation
import UIKit

class SmallTalkGroupFoundViewController: UIViewController {
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_subtitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var buttonStart: UIButton!

    var users: [User] = []
    var smallTalkId: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configurePageControl()

       // SmallTalkService.getSmallTalk(id: "\(smallTalkId)") { smallTalk, _ in
        SmallTalkService.getSmallTalk(id: "22") { smallTalk, _ in
            guard let currentUserId = UserDefaults.currentUser?.sid,
                  let members = smallTalk?.members else { return }
            self.users = members
                .filter { $0.id != currentUserId }
                .map { profile in
                    var user = User()
                    user.sid = profile.id
                    user.displayName = profile.display_name
                    user.avatarURL = profile.avatar_url
                    user.roles = profile.community_roles
                    return user
                }
            DispatchQueue.main.async {
                self.pageControl.numberOfPages = self.users.count
                self.collectionView.reloadData()
            }
        }

        buttonStart.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
    }
    
    func configure(with response: SmallTalkMatchResponse) {
        if let id = response.smalltalk_id {
            self.smallTalkId = id
        }
    }

    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false

        let layout = ZoomFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "UserProfileCell", bundle: nil), forCellWithReuseIdentifier: "UserProfileCell")
    }

    private func configurePageControl() {
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .orange
    }

    @objc private func startTapped() {
//        let vc = DetailConversationViewController() // Assure-toi que ce VC est bien configuré
//        vc.smallTalkId = "\(smallTalkId)"
//        vc.isSmallTalkMode = true
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension SmallTalkGroupFoundViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserProfileCell", for: indexPath) as? UserProfileCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: users[indexPath.item])
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / collectionView.frame.width + 0.5)
        pageControl.currentPage = page
    }
}







class ZoomFlowLayout: UICollectionViewFlowLayout {
    let scaleFactor: CGFloat = 0.2

    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = 20
        itemSize = CGSize(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.height * 0.55)
        sectionInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        let centerX = collectionView!.contentOffset.x + collectionView!.bounds.width / 2

        for attr in attributes {
            let distance = abs(attr.center.x - centerX)
            let normalizedDistance = distance / collectionView!.bounds.width
            let zoom = 1 - scaleFactor * min(1, normalizedDistance)
            attr.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
            attr.zIndex = Int(zoom * 10)
        }
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
