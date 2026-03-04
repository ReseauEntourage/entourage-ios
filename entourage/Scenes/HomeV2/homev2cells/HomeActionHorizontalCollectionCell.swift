//
//  HomeActionHorizontalCollectionCell.swift
//  entourage
//
//  Created by Clement entourage on 13/10/2023.
//

import UIKit

protocol HomeActionHCCDelegate: AnyObject {
    func goToMyActionHomeCell(action: Action)
}

enum HomeActionCollectionDTO {
    case actionCell(action: Action)
}

class HomeActionHorizontalCollectionCell: UITableViewCell {

    // OUTLET
    @IBOutlet weak var ui_collection_view: UICollectionView!

    // VARIABLE
    class var identifier: String {
        return String(describing: self)
    }

    var tableDTO = [HomeActionCollectionDTO]()
    weak var delegate: HomeActionHCCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor(named: "white_orange_home")

        ui_collection_view.delegate = self
        ui_collection_view.dataSource = self
        ui_collection_view.showsHorizontalScrollIndicator = false
        ui_collection_view.backgroundColor = .clear

        // Register the new collection view cell
        ui_collection_view.register(UINib(nibName: HomeCellActionCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: HomeCellActionCollectionViewCell.identifier)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16 // Spacing between cards
        ui_collection_view.setCollectionViewLayout(layout, animated: true)
        ui_collection_view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    func configure(actions: [Action]) {
        tableDTO.removeAll()
        for action in actions {
            tableDTO.append(.actionCell(action: action))
        }
        ui_collection_view.reloadData()
    }
}

extension HomeActionHorizontalCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableDTO.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch tableDTO[indexPath.row] {
        case .actionCell(let action):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCellActionCollectionViewCell.identifier, for: indexPath) as? HomeCellActionCollectionViewCell {
                cell.configure(action: action)
                return cell
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Requirement: "Voir 1 card entière et 1/4 de la 2ème card en proportion"
        // Screen width - left padding (16) - right padding (16) - inter item spacing (16)
        // Let's approximate. Standard width for carousel cards often takes ~80-85% of screen width.
        // Assuming iPhone width 375 (SE) or 390 (12/13/14).
        // Let's try 280-300 width for a good balance or dynamic calculation.
        // Dynamic: (UIScreen.main.bounds.width - 32) * 0.85
        let width = (UIScreen.main.bounds.width - 32) * 0.85
        return CGSize(width: width, height: 215) // Fixed height to match Event carousel or adjusted as needed
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row] {
        case .actionCell(let action):
            AnalyticsLoggerManager.logEvent(name: Action_Home_Demand_Detail) // Log click
            delegate?.goToMyActionHomeCell(action: action)
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        AnimationUtils.animateCell(cell, index: indexPath.row)
    }
}
