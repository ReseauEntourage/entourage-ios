//
//  OTHomeTableViewCells.swift
//  entourage
//
//  Created by Jr on 11/03/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

//MARK: - Protocol Clic from Cells -
protocol CellClickDelegate: class {
    func selectCollectionViewCell(item: Any,type:HomeCardType)
    func showDetail(type:HomeCardType)
    func showDetailUser(userId:NSNumber)
}

//MARK: - OTHomeCellTitleView -
class OTHomeCellTitleView: UITableViewCell {
    @IBOutlet weak var ui_title_section: UILabel!
    weak var delegate:CellClickDelegate? = nil
    var card = HomeCard()
    
    func populateCell(card:HomeCard,clickDelegate:CellClickDelegate) {
        self.delegate = clickDelegate
        self.card = card
        ui_title_section.text = card.titleSection
    }
    
    @IBAction func action_show_detail(_ sender: Any) {
        delegate?.showDetail(type: card.type)
    }
}


//MARK: - OTHomeCellCollectionView -
class OTHomeCellCollectionView: UITableViewCell,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var ui_collectionview: UICollectionView!
    @IBOutlet weak var ui_title_section: UILabel!
    
    var cards = HomeCard()
    weak var delegate:CellClickDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.ui_collectionview.showsHorizontalScrollIndicator = false
        self.ui_collectionview.dataSource = self
        self.ui_collectionview.delegate = self
    }
    
    func changeFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        if cards.type == .Headlines {
            flowLayout.itemSize = CGSize(width: 200, height: 264)
        }
        else if cards.type == .Events {
            flowLayout.itemSize = CGSize(width: 292, height: 214)
        }
        else {
            flowLayout.itemSize = CGSize(width: 200, height: 232)
        }
        
        flowLayout.minimumLineSpacing = 15.0
        flowLayout.minimumInteritemSpacing = 15.0
        self.ui_collectionview.collectionViewLayout = flowLayout
    }
    
    func populateCell(card:HomeCard,clickDelegate:CellClickDelegate) {
        self.cards = card
        self.delegate = clickDelegate
        ui_collectionview.reloadData()
        ui_title_section.text = card.titleSection
        changeFlowLayout()
    }
    
    @IBAction func action_show_detail(_ sender: Any) {
        delegate?.showDetail(type: cards.type)
    }
}

//MARK:  CollectionView Delegate / datasourece
extension OTHomeCellCollectionView: UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.arrayCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if cards.type == .Headlines {
            let item = cards.arrayCards[indexPath.row]
            if let item = item as? OTEntourage {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellColl", for: indexPath) as! OTHomeCollectionViewCell
                cell.updateCell(item: item,delegate: delegate)
                return cell
            }
            else if let item = item as? OTAnnouncement  {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollImg", for: indexPath) as! OTHomeImageCollectionViewCell
                cell.updateCell(title: item.title, imageUrl: item.image_url)
                
                return cell
            }
        }
        else if cards.type == .Events {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellColl", for: indexPath) as! OTHomeEventCollectionViewCell
            
            let item = cards.arrayCards[indexPath.row]
            if let item = item as? OTEntourage {
                cell.updateCell(item: item)
            }
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellColl", for: indexPath) as! OTHomeCollectionViewCell
        
        if let _entourage = cards.arrayCards[indexPath.row] as? OTEntourage {
            cell.updateCell(item: _entourage,delegate: delegate)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = cards.arrayCards[indexPath.row]
        let type = cards.type
        delegate?.selectCollectionViewCell(item:item,type:type)
    }
}
