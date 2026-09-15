//
//  MyEventCollectionViewCell.swift
//  entourage
//
//  Created by Clement entourage on 18/09/2023.
//

import Foundation
import UIKit
import SDWebImage


class MyEventCollectionViewCell:UICollectionViewCell{

    //Outlet
    @IBOutlet weak var ui_iv_event: UIImageView!

    @IBOutlet weak var ui_date_event: UILabel!
    @IBOutlet weak var ui_place_event: UILabel!
    @IBOutlet weak var ui_title_event: UILabel!

    /// Wash overlay applied on top of the cover image for a cancelled event (EN-9335).
    private let ui_view_cancelled_wash = UIView()
    private let ui_badge_cancelled = EventCancelledBadgeView()

    //Var
    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        self.layer.borderWidth = 1.0 // Set the width of the border
        self.layer.borderColor = UIColor.appBeige.cgColor
        self.layer.cornerRadius = 14
        self.roundCorners([.topLeft, .topRight], radius: 14)
        setupCancelledIndicators()
    }

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        ui_iv_event.layer.mask = mask
    }

    private func setupCancelledIndicators() {
        ui_view_cancelled_wash.backgroundColor = UIColor.white.withAlphaComponent(0.45)
        ui_view_cancelled_wash.isHidden = true
        ui_view_cancelled_wash.isUserInteractionEnabled = false
        ui_view_cancelled_wash.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ui_view_cancelled_wash)
        NSLayoutConstraint.activate([
            ui_view_cancelled_wash.topAnchor.constraint(equalTo: ui_iv_event.topAnchor),
            ui_view_cancelled_wash.leadingAnchor.constraint(equalTo: ui_iv_event.leadingAnchor),
            ui_view_cancelled_wash.trailingAnchor.constraint(equalTo: ui_iv_event.trailingAnchor),
            ui_view_cancelled_wash.bottomAnchor.constraint(equalTo: ui_iv_event.bottomAnchor)
        ])

        ui_badge_cancelled.isHidden = true
        ui_badge_cancelled.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ui_badge_cancelled)
        NSLayoutConstraint.activate([
            ui_badge_cancelled.topAnchor.constraint(equalTo: ui_iv_event.topAnchor, constant: 6),
            ui_badge_cancelled.leadingAnchor.constraint(equalTo: ui_iv_event.leadingAnchor, constant: 6),
            ui_badge_cancelled.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    func configure(event:Event){

        ui_title_event.text = event.title + "\n"

        if let imageUrl = event.metadata?.portrait_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            self.updateImage(mainUrl: mainUrl)
        }
        else  if let imageUrl = event.metadata?.landscape_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            self.updateImage(mainUrl: mainUrl)
        }
        else {
            ui_iv_event.image = UIImage.init(named: "ic_placeholder_event")
        }

        ui_date_event.text = event.startDateFormatted
        ui_place_event.text = event.addressName

        let isCancelled = event.isCanceled()
        ui_view_cancelled_wash.isHidden = !isCancelled
        ui_badge_cancelled.isHidden = !isCancelled
        ui_title_event.textColor = isCancelled ? .appGris112 : .black
    }

    func setPassed(){
        ui_title_event.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldGris())
    }

    func setIncoming(){
        ui_title_event.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
    }
    
    private func updateImage(mainUrl:URL) {
        ui_iv_event.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
            if error != nil {
                self?.ui_iv_event.image = UIImage.init(named: "ic_placeholder_event")
            }
        })
    }
    
}


