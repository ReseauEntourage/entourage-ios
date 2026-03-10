//
//  HomeSolidarityToolsCell.swift
//  entourage
//
//  Created by Clement entourage on 25/02/2026.
//

import UIKit

protocol HomeSolidarityToolsCellDelegate: AnyObject {
    func onMapTapped()
    func onPedagoTapped()
    func onEthicsTapped()
}

class HomeSolidarityToolsCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_stack_view: UIStackView!

    @IBOutlet weak var ui_view_map: UIView!
    @IBOutlet weak var ui_view_pedago: UIView!
    @IBOutlet weak var ui_view_ethics: UIView!

    @IBOutlet weak var ui_iv_map: UIImageView!
    @IBOutlet weak var ui_iv_pedago: UIImageView!
    @IBOutlet weak var ui_iv_ethics: UIImageView!

    @IBOutlet weak var ui_lbl_map: UILabel!
    @IBOutlet weak var ui_lbl_pedago: UILabel!
    @IBOutlet weak var ui_lbl_ethics: UILabel!

    // MARK: - Properties
    weak var delegate: HomeSolidarityToolsCellDelegate?

    class var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupTapGestures()
    }

    private func setupUI() {
        ui_label_title.text = "home_v2_solidarity_tools_title".localized
        ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: 15)
        ui_label_title.textColor = .black

        setupCard(view: ui_view_map, label: ui_lbl_map, image: ui_iv_map, title: "home_v2_tool_card_map".localized, iconName: "ic_button_map", systemIcon: "map.fill")
        setupCard(view: ui_view_pedago, label: ui_lbl_pedago, image: ui_iv_pedago, title: "home_v2_tool_card_pedago".localized, iconName: "ic_button_pedago", systemIcon: "book.fill")
        setupCard(view: ui_view_ethics, label: ui_lbl_ethics, image: ui_iv_ethics, title: "home_v2_tool_card_ethics".localized, iconName: "ic_button_charte", systemIcon: "hand.raised.fill")
    }

    private func setupCard(view: UIView, label: UILabel, image: UIImageView, title: String, iconName: String, systemIcon: String) {
        view.layer.cornerRadius = 14
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.appBeige.cgColor
        view.layer.borderWidth = 1
        view.layer.shadowColor = UIColor.clear.cgColor
        view.layer.shadowOpacity = 0

        label.text = title
        label.font = ApplicationTheme.getFontNunitoBold(size: 12)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center

        if let img = UIImage(named: iconName) {
            image.image = img
        } else {
            image.image = UIImage(systemName: systemIcon)
            image.tintColor = .appOrange
        }
        image.contentMode = .scaleAspectFit

        image.backgroundColor = UIColor.appBeige
        image.layer.cornerRadius = 25
        image.clipsToBounds = true
    }

    private func setupTapGestures() {
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        ui_view_map.addGestureRecognizer(mapTap)
        ui_view_map.isUserInteractionEnabled = true

        let pedagoTap = UITapGestureRecognizer(target: self, action: #selector(handlePedagoTap))
        ui_view_pedago.addGestureRecognizer(pedagoTap)
        ui_view_pedago.isUserInteractionEnabled = true

        let ethicsTap = UITapGestureRecognizer(target: self, action: #selector(handleEthicsTap))
        ui_view_ethics.addGestureRecognizer(ethicsTap)
        ui_view_ethics.isUserInteractionEnabled = true
    }

    @objc private func handleMapTap() {
        delegate?.onMapTapped()
    }

    @objc private func handlePedagoTap() {
        delegate?.onPedagoTapped()
    }

    @objc private func handleEthicsTap() {
        delegate?.onEthicsTapped()
    }
}
