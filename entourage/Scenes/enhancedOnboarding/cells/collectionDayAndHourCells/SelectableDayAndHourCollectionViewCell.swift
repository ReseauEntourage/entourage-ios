import Foundation
import UIKit


class SelectableDayAndHourCollectionViewCell: UICollectionViewCell {
    static let identifier = "SelectableDayAndHourCollectionViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ui_view: UIView!
    

    var title:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func configure(text: String, isSelected: Bool) {
        titleLabel.text = text
        title = text
        updateAppearance(isSelected: isSelected)

    }
    

    
    func updateAppearance(isSelected: Bool) {
        ui_view.layer.borderWidth = 1
        ui_view.layer.borderColor = isSelected ? UIColor.orange.cgColor : UIColor.lightGray.cgColor
        ui_view.backgroundColor = isSelected ? UIColor.orange.withAlphaComponent(0.1) : UIColor.clear
        titleLabel.textColor = isSelected ? UIColor.orange : UIColor.black

    }
    
}
