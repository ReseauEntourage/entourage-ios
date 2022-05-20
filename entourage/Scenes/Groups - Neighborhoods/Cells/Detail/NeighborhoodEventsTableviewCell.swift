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
        ui_collectionview.register(UINib(nibName: NeighborhoodEventsCollectionviewCell.identifier, bundle: nil), forCellWithReuseIdentifier: NeighborhoodEventsCollectionviewCell.identifier)
        
        ui_collectionview.dataSource = self
        ui_collectionview.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 136, height: 150)
        layout.scrollDirection = .horizontal
        
        ui_collectionview.setCollectionViewLayout(layout, animated: true)
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

extension NeighborhoodEventsTableviewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NeighborhoodEventsCollectionviewCell.identifier, for: indexPath) as! NeighborhoodEventsCollectionviewCell
        let event = events[indexPath.row]
        cell.populateCell(title: event.title, imageUrl: event.imageUrl, dateFormatted: event.startDateFormatted, addressName: event.addressName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        delegate?.showEvent(eventId: event.uid)
    }
}

protocol NeighborhoodEventsTableviewCellDelegate:AnyObject {
    func showAll()
    func showEvent(eventId:Int)
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
