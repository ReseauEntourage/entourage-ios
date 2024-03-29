//
//  NeighborhoodEventsTableviewCell.swift
//  entourage
//
//  Created by Jerome on 10/05/2022.
//

import UIKit

class NeighborhoodEventsTableviewCell: UITableViewCell {

    @IBOutlet weak var ui_title_section: UILabel!
    
    @IBOutlet weak var ui_collectionview: UICollectionView!
    
    @IBOutlet weak var ui_bt_show_more: UILabel!
    
    var events = [Event]()
    weak var delegate:NeighborhoodEventsTableviewCellDelegate?
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_collectionview.register(UINib(nibName: HomeCellEvent.identifier, bundle: nil), forCellWithReuseIdentifier: HomeCellEvent.identifier)

        ui_collectionview.dataSource = self
        ui_collectionview.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        ui_collectionview.setCollectionViewLayout(layout, animated: true)
        ui_title_section.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 15))
        ui_title_section.text = "neighborhood_event_group_section_title".localized
        
       let bt_more = Utils.formatStringUnderline(textString: "neighborhood_event_group_section_title_more".localized, textColor: .appOrange,font: ApplicationTheme.getFontQuickSandBold(size: 14))
        ui_bt_show_more.attributedText = bt_more
    }

    @IBAction func action_show_all(_ sender: Any) {
        delegate?.showAll()
    }
    
    func populateCell(events:[Event], delegate:NeighborhoodEventsTableviewCellDelegate) {
        self.delegate = delegate
        self.events = events
        ui_collectionview.reloadData()
    }
    
}

extension NeighborhoodEventsTableviewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCellEvent.identifier, for: indexPath) as! HomeCellEvent
        let event = events[indexPath.row]
        Logger.print("***** Event future : \(event)")
        let _addressName = event.addressName ?? ""
        cell.configure(event: event)
        //cell.populateCell(title: event.title, imageUrl: event.getCurrentImageUrl, dateFormatted: event.startDateFormatted, addressName: _addressName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        delegate?.showEvent(eventId: event.uid, isAfterCreation: false)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 215)
    }
    
}

protocol NeighborhoodEventsTableviewCellDelegate:AnyObject {
    func showAll()
    func showEvent(eventId:Int, isAfterCreation:Bool)
}


class NeighborhoodEventsCollectionviewCell: UICollectionViewCell {
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_date_location: UILabel!
    @IBOutlet weak var ui_image: UIImageView!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 14
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_date_location.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularOrange())
        
    }
    
    func populateCell(title:String,imageUrl:String?,dateFormatted:String, addressName:String) {
        ui_title.text = title
        ui_date_location.text = "\(dateFormatted)\n\(addressName)"
        
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            ui_image.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_detail_event"))
        }
        else {
            ui_image.image = UIImage.init(named: "placeholder_detail_event")
        }
    }
}
