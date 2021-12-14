//
//  OTHomeTableViewCells.swift
//  entourage
//
//  Created by Jr on 11/03/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

//MARK: - Protocol Clic from Cells -
protocol CellClickDelegate: class {
    func selectCollectionViewCell(item: Any,type:HomeCardType,position:Int)
    func showDetail(type:HomeCardType,isFromArrow:Bool,subtype:HomeCardType)
    func showDetailUser(userId:NSNumber)
    func showModifyZone()
    func showHelpDistance()
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
        delegate?.showDetail(type: card.type,isFromArrow:true,subtype: card.subtype)
    }
}


//MARK: - OTHomeCellCollectionView -
class OTHomeCellCollectionView: UITableViewCell,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var ui_collectionview: UICollectionView!
    @IBOutlet weak var ui_title_section: UILabel!
    
    var cards = HomeCard()
    weak var delegate:CellClickDelegate? = nil
    
    let cell_headline_size = CGSize(width: 200, height: 264)
    let cell_event_size = CGSize(width: 292, height: 214)
    let cell_event_zone_size = CGSize(width: 200, height: 214)
    let cell_action_size = CGSize(width: 200, height: 232)
    let cell_empty_event_size = CGSize(width: 140, height: 214)
    let cell_empty_action_size = CGSize(width: 140, height: 232)
    let cell_spacing:CGFloat = 15.0
    let minimumItemsToShowMore = 2
    let spacing_coll_start:CGFloat = 25
    let spacing_coll_end:CGFloat = 5
    var hasShowMore = false
    
    var isSpecialCells = false
    let minimalCellForSpecialCell = 1
    
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
            flowLayout.itemSize = cell_headline_size
        }
        else if cards.type == .Events {
            flowLayout.itemSize = cell_event_size
        }
        else {
            flowLayout.itemSize = cell_action_size
        }
        
        flowLayout.minimumLineSpacing = cell_spacing
        flowLayout.minimumInteritemSpacing = cell_spacing
        self.ui_collectionview.collectionViewLayout = flowLayout
    }
    
    func populateCell(card:HomeCard,clickDelegate:CellClickDelegate) {
        self.cards = card
        self.delegate = clickDelegate
        
        if card.type != .Headlines {
            self.isSpecialCells = cards.arrayCards.count <= minimalCellForSpecialCell
        }
        
        if cards.arrayCards.count >= minimumItemsToShowMore && cards.type != .Headlines{
            self.hasShowMore = true
        }
        ui_collectionview.reloadData()
        ui_title_section.text = card.titleSection
        changeFlowLayout()
    }
    
    @IBAction func action_show_detail(_ sender: Any) {
        delegate?.showDetail(type: cards.type,isFromArrow:true,subtype: cards.subtype)
    }
}

//MARK:  CollectionView Delegate / datasourece
extension OTHomeCellCollectionView: UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSpecialCells {
            if cards.type == .Events {
                return cards.arrayCards.count + 1
            }
            else if cards.type == .Actions {
                return cards.arrayCards.count + 1
            }
        }
        
        let _showMore = hasShowMore ? 1 : 0
        return cards.arrayCards.count + _showMore
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
            
            if isSpecialCells && indexPath.row == cards.arrayCards.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellOther", for: indexPath) as! OTHomeCellOther
                cell.populateCell(title: OTLocalisationService.getLocalizedValue(forKey: "home_button_modZone") , isShowZone: true)
                return cell
            }
            
            if indexPath.row == cards.arrayCards.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellEmpty", for: indexPath) as! OTHomeCellOther
                cell.ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "home_button_show_more_events")
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellColl", for: indexPath) as! OTHomeEventCollectionViewCell
            
            let item = cards.arrayCards[indexPath.row]
            if let item = item as? OTEntourage {
                cell.updateCell(item: item)
            }
            
            return cell
        }
        
        if isSpecialCells && indexPath.row == cards.arrayCards.count {
            if cards.subtype == .ActionsAsk {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellOther", for: indexPath) as! OTHomeCellOther
                cell.populateCell(title: OTLocalisationService.getLocalizedValue(forKey: "cell_info_demand_empty"),buttonMoreTxt: OTLocalisationService.getLocalizedValue(forKey: "cell_info_demand_empty_button"))
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellOther", for: indexPath) as! OTHomeCellOther
            cell.populateCell(title: OTLocalisationService.getLocalizedValue(forKey: "home_button_helpEntourage"), isShowZone: true)
            return cell
        }
        
        if indexPath.row == cards.arrayCards.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellEmpty", for: indexPath) as! OTHomeCellOther
            if cards.subtype == .ActionsAsk {
                cell.ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "home_button_show_more_actions_ask")
            }
            else if cards.subtype == .ActionsContrib {
                cell.ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "home_button_show_more_actions_contrib")
            }
            else {
                cell.ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "home_button_show_more_actions")
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
        return UIEdgeInsets(top: 0, left: spacing_coll_start, bottom: 0, right: spacing_coll_end)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isSpecialCells && indexPath.row == cards.arrayCards.count {
            if cards.type == .Events {
                delegate?.showModifyZone()
            }
            else {
                if cards.subtype == .ActionsAsk {
                    delegate?.showDetail(type: cards.type,isFromArrow:true,subtype: cards.subtype)
                    return
                }
                delegate?.showHelpDistance()
            }
            return
        }
        
        if indexPath.row == cards.arrayCards.count {
            delegate?.showDetail(type: cards.type,isFromArrow:false,subtype: cards.subtype)
            return
        }
        let item = cards.arrayCards[indexPath.row]
        let type = cards.type
        delegate?.selectCollectionViewCell(item:item,type:type,position: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cards.type == .Headlines {
            return cell_headline_size
        }
        else if cards.type == .Events {
            if isSpecialCells && indexPath.row == cards.arrayCards.count {
                return cell_event_zone_size
            }
            
            if indexPath.row == cards.arrayCards.count {
                return cell_empty_event_size
            }
            return cell_event_size
        }
        else {
            if isSpecialCells && indexPath.row == cards.arrayCards.count {
                return cell_action_size
            }
            
            if indexPath.row == cards.arrayCards.count {
                return cell_empty_action_size
            }
            return cell_action_size
        }
    }
}
