//
//  ImageListViewController.swift
//  entourage
//
//  Created by Clement entourage on 02/10/2025.
//

import Foundation
import UIKit

class ImageListViewController: UIViewController {
    var conversationId: Int = 0
    
    private var collectionView: UICollectionView!
    @IBOutlet weak var ui_image_btn_back: UIImageView!
    
    private var images: [ConversationImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupBack()
        setupCollection()
        fetchImages()
    }
    
    private func setupBack() {
        if let back = ui_image_btn_back {
            back.isUserInteractionEnabled = true
            back.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBack)))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "ic_back"),
                style: .plain,
                target: self,
                action: #selector(tapBack)
            )
        }
    }
    
    @objc private func tapBack() { navigationController?.popViewController(animated: true) }
    
    private func setupCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let sidePadding: CGFloat = 16
        let columns: CGFloat = 3
        let itemWidth = floor((view.bounds.width - sidePadding*2 - (columns-1)*layout.minimumInteritemSpacing) / columns)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = UIEdgeInsets(top: 12, left: sidePadding, bottom: 12, right: sidePadding)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(ImageGridCell.self, forCellWithReuseIdentifier: ImageGridCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let topAnchor = (ui_image_btn_back?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchImages() {
        MessagingService.getConversationImages(conversationId: conversationId) { [weak self] imgs, _ in
            self?.images = imgs ?? []
            self?.collectionView.reloadData()
        }
    }
}

extension ImageListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageGridCell.reuseId, for: indexPath) as! ImageGridCell
        let item = images[indexPath.item]
        cell.spinner.startAnimating()
        if let urlStr = item.url {
            ImageCache.shared.load(urlStr) { img in
                if collectionView.indexPath(for: cell) == indexPath {
                    cell.imageView.image = img
                    cell.spinner.stopAnimating()
                }
            }
        } else {
            cell.spinner.stopAnimating()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = images[indexPath.item].chatMessageId else { return }
        let vc = ImagePreviewController(conversationId: conversationId, chatMessageId: id)
        present(vc, animated: true)
    }
}
