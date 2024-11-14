import UIKit

protocol ChoiceDayCellDelegate: AnyObject {
    func choiceDayCell(_ cell: ChoiceDayCell, didUpdateSelectedDays selectedDays: Set<Int>, isDay: Bool)
}

class ChoiceDayCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var ui_title_day: UILabel!
    @IBOutlet weak var ui_collectionview_days: UICollectionView!

    static let identifier = "ChoiceDayCell"

    var days: [String] = []
    var selectedDays: Set<Int> = []
    var isDay = false

    weak var delegate: ChoiceDayCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_collectionview_days.delegate = self
        ui_collectionview_days.dataSource = self

        let nib = UINib(nibName: "SelectableDayAndHourCollectionViewCell", bundle: nil)
        ui_collectionview_days.register(nib, forCellWithReuseIdentifier: SelectableDayAndHourCollectionViewCell.identifier)
        
        // Ajout du tapGesture pour la gestion manuelle des clics
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCollectionViewTap(_:)))
        ui_collectionview_days.addGestureRecognizer(tapGesture)
    }

    @objc private func handleCollectionViewTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: ui_collectionview_days)
        
        if let indexPath = ui_collectionview_days.indexPathForItem(at: point),
           let cell = ui_collectionview_days.cellForItem(at: indexPath) as? SelectableDayAndHourCollectionViewCell {
            
            if selectedDays.contains(indexPath.item) {
                selectedDays.remove(indexPath.item)
                cell.updateAppearance(isSelected: false)
            } else {
                selectedDays.insert(indexPath.item)
                cell.updateAppearance(isSelected: true)
            }
            print("eho list " , selectedDays)
            // Appelle le délégué avec les selectedDays mis à jour
            delegate?.choiceDayCell(self, didUpdateSelectedDays: selectedDays, isDay: self.isDay)
        }
    }


    func configure(days: [String]) {
        self.days = days
        ui_collectionview_days.reloadData()
    }

    // MARK: - UICollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectableDayAndHourCollectionViewCell.identifier,
            for: indexPath
        ) as? SelectableDayAndHourCollectionViewCell else {
            fatalError("Could not dequeue cell with identifier: \(SelectableDayAndHourCollectionViewCell.identifier)")
        }

        let itemText = days[indexPath.item]
        let isSelected = selectedDays.contains(indexPath.item)
        
        // Configure la cellule avec le texte et l'état de sélection
        cell.configure(text: itemText, isSelected: isSelected)
        
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = days[indexPath.item]
        label.font = UIFont.systemFont(ofSize: 16)
        label.sizeToFit()
        
        let width = label.frame.width + 24
        let height: CGFloat = 30
        
        return CGSize(width: width, height: height)
    }
}
